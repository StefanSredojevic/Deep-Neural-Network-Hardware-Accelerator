library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SyncAsync is
   Generic (
      kResetTo : std_logic := '0'; --value when reset and upon init
      kStages : natural := 2); --double sync by default
   Port (
      aReset : in STD_LOGIC; -- active-high asynchronous reset
      aIn : in STD_LOGIC;
      OutClk : in STD_LOGIC;
      oOut : out STD_LOGIC);
end SyncAsync;

architecture Behavioral of SyncAsync is
signal oSyncStages : std_logic_vector(kStages-1 downto 0) := (others => kResetTo);
attribute ASYNC_REG : string;
attribute ASYNC_REG of oSyncStages: signal is "TRUE";
begin

Sync: process (OutClk, aReset)
begin
   if (aReset = '1') then
      oSyncStages <= (others => kResetTo);
   elsif Rising_Edge(OutClk) then
      oSyncStages <= oSyncStages(oSyncStages'high-1 downto 0) & aIn;
   end if;
end process Sync;
oOut <= oSyncStages(oSyncStages'high);

end Behavioral;
