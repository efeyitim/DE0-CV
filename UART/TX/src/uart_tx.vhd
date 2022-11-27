---------------------------------------------------------------------------------------------------
--  Project Name        :   Generic
--  System/Block Name   :   UART TX
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
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        CLK_FREQ      : integer := 50_000_000;
        BAUD_RATE     : integer := 115_200;
        NUM_DATA_BITS : integer := 8;
        NUM_STOP_BITS : integer := 1
        );

    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        tx_din   : in  std_logic_vector (7 downto 0);
        tx_start : in  std_logic;
        tx       : out std_logic;
        tx_busy  : out std_logic;
        tx_done  : out std_logic
        );
end uart_tx;

architecture Behavioral of uart_tx is

    constant DATA_BIT_TIME : unsigned(31 downto 0) := to_unsigned(CLK_FREQ / BAUD_RATE, 32);
    constant STOP_BIT_TIME : unsigned(31 downto 0) := to_unsigned((CLK_FREQ / BAUD_RATE) * NUM_STOP_BITS, 32);
    constant DATA_BITS     : unsigned(3 downto 0)  := to_unsigned(NUM_DATA_BITS - 1, 4);

    type t_state is (IDLE_S, START_S, STOP_S, DATA_S);
    signal state : t_state;

    signal bit_timer   : unsigned(31 downto 0);
    signal bit_counter : unsigned(3 downto 0);
    signal shift_reg   : std_logic_vector (7 downto 0);

begin

    PROC_UART_TX : process (clk, rst_n)
    begin
        if rst_n = '0' then
            shift_reg   <= (others => '0');
            bit_counter <= DATA_BITS;
            bit_timer   <= DATA_BIT_TIME;
            tx_done     <= '0';
            tx          <= '1';
            tx_busy     <= '0';
            state       <= IDLE_S;

        elsif (rising_edge(clk)) then
            case state is

                when IDLE_S =>
                    tx_done       <= '0';
                    if (tx_start = '1') then
                        state     <= START_S;
                        tx        <= '0';
                        tx_busy   <= '1';
                        shift_reg <= tx_din;
                    else
                        tx        <= '1';
                    end if;

                when START_S =>
                    if (bit_timer = 0) then
                        state                  <= DATA_S;
                        tx                     <= shift_reg(0);
                        shift_reg (7)          <= shift_reg(0);
                        shift_reg (6 downto 0) <= shift_reg(7 downto 1);
                        bit_timer              <= DATA_BIT_TIME;
                    else
                        bit_timer              <= bit_timer - 1;
                    end if;

                when DATA_S =>
                    if (bit_counter = 0) then
                        if (bit_timer = 0) then
                            state                  <= STOP_S;
                            bit_counter            <= DATA_BITS;
                            tx                     <= '1';
                            bit_timer              <= STOP_BIT_TIME;
                        else
                            bit_timer              <= bit_timer - 1;
                        end if;
                    else
                        if (bit_timer = 0) then
                            shift_reg (7)          <= shift_reg(0);
                            shift_reg (6 downto 0) <= shift_reg(7 downto 1);
                            tx                     <= shift_reg(0);
                            bit_counter            <= bit_counter - 1;
                            bit_timer              <= DATA_BIT_TIME;
                        else
                            bit_timer              <= bit_timer - 1;
                        end if;
                    end if;

                when STOP_S =>
                    if (bit_timer = 0) then
                        state     <= IDLE_S;
                        tx_busy   <= '0';
                        tx_done   <= '1';
                        bit_timer <= DATA_BIT_TIME;
                    else
                        bit_timer <= bit_timer - 1;
                    end if;

                when others =>
                    shift_reg   <= (others => '0');
                    bit_counter <= DATA_BITS;
                    bit_timer   <= DATA_BIT_TIME;
                    tx_done     <= '0';
                    tx          <= '1';
                    tx_busy     <= '0';
                    state       <= IDLE_S;

            end case;
        end if;
    end process PROC_UART_TX;
end Behavioral;
