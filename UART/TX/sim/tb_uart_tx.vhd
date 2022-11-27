---------------------------------------------------------------------------------------------------
--  Project Name        :
--  System/Block Name   :
--  Design Engineer     :   Efe Berkay YITIM
--  Date                :   27.11.2022
--  Short Description   :   
---------------------------------------------------------------------------------------------------
--  Revisions
--  Designer            Date            Description
--  -----------         ----------      -----------------------------------------------------------
--  Efe Berkay YITIM    27.11.2022          v1.0 Initial Release
---------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------------------------------------------------------------------------------------------------

entity tb_uart_tx is

end entity tb_uart_tx;

------------------------------------------------------------------------------------------------------------------------------------------------------

architecture tb of tb_uart_tx is

    -- component generics
    constant CLK_FREQ      : integer := 50_000_000;
    constant BAUD_RATE     : integer := 115_200;
    constant NUM_DATA_BITS : integer := 8;
    constant NUM_STOP_BITS : integer := 1;

    -- component ports
    signal clk      : std_logic                     := '0';
    signal rst_n    : std_logic                     := '0';
    signal tx_din   : std_logic_vector (7 downto 0) := (others => '0');
    signal tx_start : std_logic                     := '0';
    signal tx       : std_logic;
    signal tx_busy  : std_logic;
    signal tx_done  : std_logic;


    procedure waitNre(signal clock: std_ulogic; n: positive) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clock);
        end loop;
    end procedure waitNre;

begin  -- architecture tb

    -- component instantiation
    U_DUT: entity work.uart_tx
        generic map (
            CLK_FREQ      => CLK_FREQ,
            BAUD_RATE     => BAUD_RATE,
            NUM_DATA_BITS => NUM_DATA_BITS,
            NUM_STOP_BITS => NUM_STOP_BITS)
        port map (
            clk      => clk,
            rst_n    => rst_n,
            tx_din   => tx_din,
            tx_start => tx_start,
            tx       => tx,
            tx_busy  => tx_busy,
            tx_done  => tx_done);

    -- clock generation
    clk <= not clk after 10 ns;

    -- waveform generation
    PROC_STIMULI: process
    begin
        -- insert signal assignments here
        rst_n <= '0';
        waitNre(clk, 5);
        rst_n <= '1';
        waitNre(clk, 100);
        tx_din <= x"C3";
        tx_start <= '1';
        wait until rising_edge(tx_busy);
        tx_start <= '0';
        wait until tx_busy = '0';
        tx_din <= x"F0";
        tx_start <= '1';
        wait until rising_edge(tx_busy);
        tx_start <= '0';
        wait until tx_busy = '0';
        waitNre(clk, 100);
        report "SIM DONE" severity failure;
        wait;
    end process PROC_STIMULI;
    

end architecture tb;

------------------------------------------------------------------------------------------------------------------------------------------------------
    
