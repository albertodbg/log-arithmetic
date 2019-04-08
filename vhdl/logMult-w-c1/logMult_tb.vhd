--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM) and Min Soo Kim (UCI)
-- This is the top file for an 8-bit logarithmic Mitchell multiplier with a truncated
-- Mitchell's decoder and unbiased operators. In this case K=6
-- Negative numbers are also supported thanks to the C1 transform
-- A detailed description can be found in
-- M. S. Kim, A. A. Del Barrio Garcia, L. T. Oliveira, R. Hermida and N. Bagherzadeh, "Efficient Mitchell's Approximate Log Multipliers for Convolutional 
-- Neural Networks," in IEEE Transactions on Computers. doi: 10.1109/TC.2018.2880742
-- Note that the paper names this as Mitch-w in order to avoid the confusion with the characteristic representation (k)
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity logMult_tb is
	port(
	  a: in std_logic_vector(15 downto 0);
	  b: in std_logic_vector(15 downto 0);
		z: out std_logic_vector(31 downto 0)
	);
end logMult_tb;

architecture estr of logMult_tb is

  --Components
  
  component logMultK_Neg is
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
  end component;
  
  --Signals
  
begin
            
  --K=6
  ln: logMultK_Neg generic map(16,4,2,6,3)
            port map(a,b,z);
   
end estr;



















