--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a Leading One Detector for an N-bit value
-- The output is a string of N bits where only the leading one position contains a '1'
-- This implementation was first used in
-- M. S. Kim, A. A. Del Barrio, R. Hermida and N. Bagherzadeh, 
-- "Low-power implementation of Mitchell's approximate logarithmic multiplication for convolutional neural networks," 
-- 2018 23rd Asia and South Pacific Design Automation Conference (ASP-DAC), Jeju, 2018, pp. 617-622. 
-- doi: 10.1109/ASPDAC.2018.8297391
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lod is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  d: in std_logic_vector((N-1) downto 0);
		z: out std_logic_vector((N-1) downto 0)
	);
end lod;

architecture estr of lod is

  --Components
  
  --Types
  type matrixInd is array (0 to LOG_N) of std_logic_vector((N-1) downto 0);
  
  --Signals
  signal matrixMZ: matrixInd;--Fi matrix indicators
  
begin
  
  --Indicators tree like calculation
  genStage0:
  for i in 0 to (N-1) generate
    matrixMZ(0)(i) <= d(i);
  end generate genStage0;
  genStagesI:
  for i in 1 to (LOG_N) generate
    genStageI:
    for j in (N-1) downto 0 generate
      ifgenCopy:
      if ((N-1-j) < 2**(i-1)) generate
        matrixMZ(i)(j) <= matrixMZ(i-1)(j);
      end generate ifgenCopy;
      ifgenCalculate:
      if ((N-1-j) >= 2**(i-1)) generate
        matrixMZ(i)(j) <= matrixMZ(i-1)(j) or matrixMZ(i-1)(j+2**(i-1));
      end generate ifgenCalculate;
    end generate genStageI;
  end generate genStagesI;
  
  --Copy indicators
  z(N-1) <= d(N-1);
  z(N-2 downto 0) <= d((N-2) downto 0) and not(matrixMZ(LOG_N)((N-1) downto 1));
  
end estr;















