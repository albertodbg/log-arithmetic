--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This is a 2to1 N-bit multiplexer
--///////////////////////////////////////////////////////////////////////
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mux2to1 is
   generic(N: integer);
	port(
		x0: in std_logic_vector((N-1) downto 0);
		x1: in std_logic_vector((N-1) downto 0);
		ctrl: in std_logic;
		z: out std_logic_vector((N-1) downto 0)
	);
end mux2to1;

architecture estr of mux2to1 is

  --Signals
  
  signal a1: std_logic_vector((N-1) downto 0);
  signal a2: std_logic_vector((N-1) downto 0);

begin
    
    genAnds:
    for i in 0 to (N-1) generate
      a1(i) <= x0(i) and not(ctrl);
      a2(i) <= x1(i) and ctrl;
    end generate genAnds;
    
    z <= a1 or a2;
    
end estr;

