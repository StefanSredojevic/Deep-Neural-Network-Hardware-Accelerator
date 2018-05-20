library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ResetBridge is
   Generic (
      kPolarity : std_logic := '1');
   Port (
      aRst : in STD_LOGIC; -- asynchronous reset; active-high, if kPolarity=1
      OutClk : in STD_LOGIC;
      oRst : out STD_LOGIC);
end ResetBridge;

architecture Behavioral of ResetBridge is
signal aRst_int : std_logic;
attribute KEEP : string;
attribute KEEP of aRst_int: signal is "TRUE";
begin

aRst_int <= kPolarity xnor aRst; --SyncAsync uses active-high reset

SyncAsyncx: entity work.SyncAsync
   generic map (
      kResetTo => kPolarity,
      kStages => 2) --use double FF synchronizer
   port map (
      aReset => aRst_int,
      aIn => not kPolarity,
      OutClk => OutClk,
      oOut => oRst);

end Behavioral;
