--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM) and Min Soo Kim (UCI)
-- This module implements a logarithmic Mitchell decoder with a truncated
-- Mitchell's decoder and unbiased operators
-- A detailed description can be found in
-- M. S. Kim, A. A. Del Barrio Garcia, L. T. Oliveira, R. Hermida and N. Bagherzadeh, "Efficient Mitchell's Approximate Log Multipliers for Convolutional 
-- Neural Networks," in IEEE Transactions on Computers. doi: 10.1109/TC.2018.2880742
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.all;

entity mitchellDecoderK is
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
end mitchellDecoderK;

architecture estr of mitchellDecoderK is

  --Components
  
  component barrelShifter1 is
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
  
  component barrelShifterR is
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
  
  component mux2to1 is
   generic(N: integer);
	port(
		x0: in std_logic_vector((N-1) downto 0);
		x1: in std_logic_vector((N-1) downto 0);
		ctrl: in std_logic;
		z: out std_logic_vector((N-1) downto 0)
	);
  end component;
  
  --Signals
  signal charac: std_logic_vector(LOG_N downto 0);
  signal mantissa: std_logic_vector((K-2) downto 0);
  signal mantissa_aux: std_logic_vector((N+K-1) downto 0);
  signal shamtL: std_logic_vector(LOG_N downto 0);
  signal shL: std_logic_vector((mantissa_aux'length-1) downto 0);
  signal shamtR: std_logic_vector((LOG_K-1) downto 0);
  signal shR: std_logic_vector((K-1) downto 0);
  signal characsN: std_logic_vector((N-1) downto 0);
  signal shamtMask: std_logic_vector((LOG_N-1) downto 0);
  
begin
  
  --Decomposition of the input
  charac <= res((K+LOG_N-1) downto (K-1));
  mantissa <= res((K-2) downto 0);
  
  mantissa_aux((N+K-1) downto K) <= (OTHERS => '0');
  mantissa_aux((K-1) downto 0) <= '1' & mantissa((K-2) downto 0);
  
  --Left shift
  
  --Opt1
  shamtL <= '0' & charac((LOG_N-1) downto 0);
  shiftL: barrelShifter1 generic map(N+K,LOG_N+1)
        port map(mantissa_aux,shamtL,shL);
        
  --Right shift
  shamtR <= not(charac((LOG_N-1) downto (LOG_N-LOG_K)));
  
  shiftR: barrelShifterR generic map(K,LOG_K)
        port map(mantissa_aux((N-1) downto (N-K)),shamtR,shR);
        
  --Mux
  
  characsN <= (OTHERS => charac(LOG_N));
  z((2*N-1) downto N) <= shL((N+K-1) downto K) and characsN;
  
    
  muxOut: mux2to1 generic map(K)
        port map(shR,shL((K-1) downto 0),charac(LOG_N),z((N-1) downto (N-K)));
        
  z((N-K-1) downto 0) <= (OTHERS => '0');                  
  
end estr;





















