--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM) and Min Soo Kim (UCI)
-- This module implements a logarithmic Mitchell multiplier with a truncated
-- Mitchell's decoder and unbiased operands
-- Also, negative numbers are approximated thanks to the C1 transform
-- A detailed description can be found in
-- M. S. Kim, A. A. Del Barrio Garcia, L. T. Oliveira, R. Hermida and N. Bagherzadeh, "Efficient Mitchell's Approximate Log Multipliers for Convolutional 
-- Neural Networks," in IEEE Transactions on Computers. doi: 10.1109/TC.2018.2880742
-- Note that the paper names this as Mitch-w in order to avoid the confusion with the characteristic representation (k)
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity logMultK_Neg is
  generic(
    N: integer;
    LOG_N: integer;
    LOG_LOG_N: integer;
    K: integer;
    LOG_K: integer
  );
	port(
	  a: in std_logic_vector((N-1) downto 0);
	  b: in std_logic_vector((N-1) downto 0);
		z: out std_logic_vector((2*N-1) downto 0)
	);
end logMultK_Neg;

architecture estr of logMultK_Neg is

  --Components
  
  component lod is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  d: in std_logic_vector((N-1) downto 0);
		z: out std_logic_vector((N-1) downto 0)
	);
  end component;
  
  component encoder is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
		enc: out std_logic_vector((LOG_N-1) downto 0)
	);
  end component;
  
  component barrelShifter is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
	  shiftAm: in std_logic_vector((LOG_N-1) downto 0);
	  shX: out std_logic_vector((N-1) downto 0)
	);
  end component;
  
  component orTree is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
		z: out std_logic
	);
  end component;
  
  component mux2to1 is
   generic(N: integer);
	port(
		x0: in std_logic_vector((N-1) downto 0);
		x1: in std_logic_vector((N-1) downto 0);
		ctrl: in std_logic;
		z: out std_logic_vector((N-1) downto 0)
	);
  end component;
  
  component mitchellDecoderK is
  generic(
    N: integer;
    LOG_N: integer;
    K: integer;
    LOG_K: integer
  );
	port(
	  res: in std_logic_vector((K+LOG_N-1) downto 0);
	  z: out std_logic_vector((2*N-1) downto 0)
	);
  end component;

  
  --Signals
  signal a_lod: std_logic_vector((a'length-1) downto 0);
  signal b_lod: std_logic_vector((b'length-1) downto 0);
  signal a_enc: std_logic_vector((LOG_N-1) downto 0);
  signal b_enc: std_logic_vector((LOG_N-1) downto 0);
  signal a_shamt: std_logic_vector((LOG_N-1) downto 0);
  signal b_shamt: std_logic_vector((LOG_N-1) downto 0);
  signal a_sh: std_logic_vector((a'length-1) downto 0);
  signal b_sh: std_logic_vector((b'length-1) downto 0);
  signal a_aux: std_logic_vector((a'length-1) downto 0);
  signal b_aux: std_logic_vector((b'length-1) downto 0);
  signal notZero_a: std_logic;
  signal notZero_b: std_logic;
  signal notZero: std_logic;
  signal op1: std_logic_vector((K+LOG_N-1) downto 0);
  signal op2: std_logic_vector((K+LOG_N-1) downto 0);
  signal res: std_logic_vector((K+LOG_N-1) downto 0);
  signal a_ms: std_logic;
  signal b_ms: std_logic;
  signal a_msN: std_logic_vector((N-1) downto 0);
  signal b_msN: std_logic_vector((N-1) downto 0);
  signal a_c1: std_logic_vector((N-1) downto 0);
  signal b_c1: std_logic_vector((N-1) downto 0);
  signal z_sign: std_logic;
  signal z_sign2N: std_logic_vector((2*N-1) downto 0);
  signal z_aux_c1: std_logic_vector((2*N-1) downto 0);
  signal z_aux: std_logic_vector((2*N-1) downto 0);
  signal notZeros: std_logic_vector((2*N-1) downto 0);
  
begin
  
  --C1 CONVERSION
  a_ms <= a(N-1);
  b_ms <= b(N-1);
  a_msN <= (OTHERS => a_ms);
  b_msN <= (OTHERS => b_ms);
  a_c1 <= a xor a_msN;
  b_c1 <= b xor b_msN;
  
  --LOD
  lone_a: lod generic map(N,LOG_N)
            port map(a_c1,a_lod);
            
  lone_b: lod generic map(N,LOG_N)
            port map(b_c1,b_lod);
            
  --ENC
  enc_a: encoder generic map(N,LOG_N)
            port map(a_lod,a_enc);
            
  enc_b: encoder generic map(N,LOG_N)
            port map(b_lod,b_enc);
            
  --SHIFT
  --C1's arithmetic
  a_shamt <= not(a_enc);
  b_shamt <= not(b_enc);
  
  a_aux <= a_c1;
  b_aux <= b_c1;
  
  ifLeq16:
  if (N <= 16) generate--Synthesizes better
      a_sh <= std_logic_vector(shift_left(unsigned(a_aux), to_integer(unsigned(a_shamt))));
      b_sh <= std_logic_vector(shift_left(unsigned(b_aux), to_integer(unsigned(b_shamt))));
  end generate ifLeq16;
  
  ifGt16:
  if (N > 16) generate
      bsh_a: barrelShifter generic map(N,LOG_N)
            port map(a_aux,a_shamt,a_sh);
            
      bsh_b: barrelShifter generic map(N,LOG_N)
             port map(b_aux,b_shamt,b_sh);
  end generate ifGt16;
            
  --ADD
  
  op1 <= ('0' & a_enc & a_sh((N-2) downto (N-K+1)) & '1');
  op2 <= ('0' & b_enc & b_sh((N-2) downto (N-K+1)) & '1');
  res <= op1 + op2;
  
  --DEC
  decod: mitchellDecoderK generic map(N,LOG_N,K,LOG_K)
            port map(res,z_aux);
            
  --C1 COMPLEMENT FOR Z
  
  z_sign <= a_ms xor b_ms;
  z_sign2N <= (OTHERS => z_sign);
  z_aux_c1 <= z_aux xor z_sign2N;
            
  --CHECK IF ZERO
  
  ot_a: orTree generic map(LOG_N,LOG_LOG_N)
            port map(a_enc,notZero_a);
            
  ot_b: orTree generic map(LOG_N,LOG_LOG_N)
            port map(b_enc,notZero_b);
            
  notZero <= (notZero_a or a_ms or a(0)) and (notZero_b or b_ms or b(0));
  
  --Out
  notZeros <= (OTHERS => notZero);
  z <= z_aux_c1 and notZeros;
  
end estr;


























