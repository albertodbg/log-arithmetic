--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements an encoder without priority
-- We suppose that only an input can be '1'
-- x(N-1) is the msb
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity encoder is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
		enc: out std_logic_vector((LOG_N-1) downto 0)
	);
end encoder;

architecture estr of encoder is

  --Components
  
  --Types
  type matrixEnc is array ((LOG_N-1) downto 0) of 
        std_logic_vector(N downto 0);
  
  --Signals
  signal matrix: matrixEnc;
  signal shift2: std_logic_vector((LOG_N-1) downto 0);
  
begin
  
  --Shift encoding
  --Initializing
  genInitMat:
  for i in (LOG_N-1) downto 0 generate
    matrix(i)(N) <= '0';
  end generate genInitMat;
  --Generating shift
  genEncoding:
  for i in (LOG_N-1) downto 0 generate
    genOrJ:
    for j in (N-1) downto 0 generate
      ifGenBit:
      if (((j) mod 2**(i+1))>=2**i) generate
        matrix(i)(j) <= matrix(i)(j+1) or x(j);
      end generate ifGenBit;
      ifNGenBit:
      if (((j) mod 2**(i+1))<2**i) generate
        matrix(i)(j) <= matrix(i)(j+1);
      end generate ifNGenBit;
    end generate genOrJ;
  end generate genEncoding;
  --Copying
  genCopy:
  for i in (LOG_N-1) downto 0 generate
    shift2(i) <= matrix(i)(0);
  end generate genCopy;
    
  enc <= shift2;  
end estr;















