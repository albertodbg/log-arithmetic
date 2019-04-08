--///////////////////////////////////////////////////////////////////////
-- By Alberto A. Del Barrio (UCM)
-- This module implements a customized left barrel shifter for an n-bit value
-- The final shift is increased in one extra left shift
-- In other words, the actual shamt = shiftAm + 1
-- Instead of adding, we just customize the shifter to always shift one extra position
--///////////////////////////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity barrelShifter1 is
  generic(
    N: integer;
    LOG_N: integer
  );
	port(
	  x: in std_logic_vector((N-1) downto 0);
	  shiftAm: in std_logic_vector((LOG_N-1) downto 0);
	  shX: out std_logic_vector((N-1) downto 0)
	);
end barrelShifter1;

architecture estr of barrelShifter1 is
  
  --Components
  component mux2to1Simple is
	 port(
		  x0: in std_logic;
		  x1: in std_logic;
		  ctrl: in std_logic;
		  z: out std_logic
	 );
  end component;

  --Types
  
  type matrix is array(0 to LOG_N) of std_logic_vector((N-1) downto 0);
  
  --Signals
  
  signal muxMat: matrix;
  signal zero1: std_logic;
  
begin
  
  zero1 <= '0';
  
  --Stage 0
  muxMat(0) <= x;   
  
  --Stage 1
  --If shift, then shift two positions
  --If not shift, then shift one position
  --i=1
  muxMat(1)(0) <= '0';--j=0
  muxMat(1)(1) <= muxMat(0)(0) and not(shiftAm(0));--j=1
  genStage1:--j>=2
  for j in 2 to (N-1) generate
      muxSh_st1: mux2to1Simple port map(muxMat(0)(j-1),muxMat(0)(j-2),
           shiftAm(0),muxMat(1)(j));
  end generate genStage1;
   
  --StagesI
  genStagesI:
  for i in 2 to LOG_N generate
     genStageI:
     for j in 0 to (N-1) generate
        ifgenCte:
        if (j < 2**(i-1)) generate
           muxMat(i)(j) <= muxMat(i-1)(j) and not(shiftAm(i-1));
        end generate ifgenCte;
        ifgenSh:
        if (j >= 2**(i-1)) generate
          muxSh: mux2to1Simple port map(muxMat(i-1)(j),muxMat(i-1)(j-2**(i-1)),
              shiftAm(i-1),muxMat(i)(j));  
        end generate ifgenSh;
     end generate genStageI;
  end generate genStagesI;
  
  shX <= muxMat(LOG_N);
  
end estr;














