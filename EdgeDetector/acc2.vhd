-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  YOUR NAME HERE - s??????@student.dtu.dk
--             :  YOUR NAME HERE - s??????@student.dtu.dk
--             :
--  Purpose    :  This design contains an entity for the accelerator that must be build
--             :  in task two of the Edge Detection design project. It contains an
--             :  architecture skeleton for the entity as well.
--             :
--  Revision   :  1.0   ??-??-??     Final version
--             :
--
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- The entity for task two. Notice the additional signals for the memory.
-- reset is active high.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity convoluter is
    port(
        s11     : in  byte_t;
        s12     : in  byte_t;
        s13     : in  byte_t;
        s21     : in  byte_t;
        s22     : in  byte_t;
        s23     : in  byte_t;
        s31     : in  byte_t;
        s32     : in  byte_t;
        s33     : in  byte_t;
        res     : out byte_t);
end entity;

architecture structure of convoluter is
    begin
end structure;






library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity acc is
    port(
        clk    : in  bit_t;             -- The clock.
        reset  : in  bit_t;             -- The reset signal. Active high.
        addr   : out halfword_t;        -- Address bus for data.
        dataR  : in  word_t;            -- The data bus.
        dataW  : out word_t;            -- The data bus.
        en     : out bit_t;             -- Request signal for data.
        we     : out bit_t;             -- Read/Write signal for data.
        start  : in  bit_t;
        finish : out bit_t
    );
end acc;

--------------------------------------------------------------------------------    
-- The desription of the accelerator.
--------------------------------------------------------------------------------

architecture rtl of acc is

    constant IMG_WIDTH  : natural := 352;
    constant IMG_HEIGHT : natural := 288;
    constant IMG_SIZE   : natural := IMG_WIDTH * IMG_HEIGHT;
    
    type state_type is (IDLE, Pre_R, Continuous_R, R, W, F); -- Input your own state names
    signal state, next_state : state_type;

    type buf_type is array (2 downto 0, IMG_WIDTH downto 0) of byte_t;
    signal buf: buf_type := (others => (others => (others => '0')));
--  signal var : unsigned(31 downto 0);

    signal addr_r, next_addr_r: unsigned(15 downto 0) := (others=>'0');
    signal addr_w, next_addr_w: unsigned(15 downto 0) := to_unsigned(((IMG_SIZE + IMG_WIDTH) / 4), 16);    --Start writing from the 2nd line
    
begin

    process(clk,reset) 
    begin 
        if reset='1' then 
            state <= idle; 
            addr_r <= (others=>'0');
            addr_w <= to_unsigned(((IMG_SIZE + IMG_WIDTH) / 4), 16);
        elsif rising_edge(clk) then 
            state <= next_state; 
            addr_r <= next_addr_r;
            addr_w <= next_addr_w;
        end if; 
    end process;


    process(reset, dataR, start, state, addr_r, addr_w)
    
--    variable data_var: unsigned(31 downto 0);
--    variable addr_r: unsigned(15 downto 0) := (others=>'0');
--    variable addr_w: unsigned(15 downto 0) := to_unsigned(((IMG_SIZE + IMG_WIDTH) / 4), 16);    --Start writing from the 2nd line
    variable r_p_x: integer :=0;        --read pointer x
    variable r_p_y: integer :=0;        --read pointer y
    begin 
        next_state <= state;
        addr <= (others=>'0');
        dataW <= (others=>'0');
        en <= '0';
        we <= '0';
        finish <= '0';
        next_addr_r <= addr_r;
        next_addr_w <= addr_w;

        case state is 
            when IDLE =>
                if start = '1' then
                    next_state <= Pre_R;
                end if;

            when Pre_R =>             --prepare to read the first word
                addr <= std_logic_vector(addr_r);
                en <= '1';
                next_addr_r <= addr_r + 1;
                next_state <= Continuous_R;

            when Continuous_R =>       --continuous read until the 2nd word of the 3rd line
                addr <= std_logic_vector(addr_r);
                next_addr_r <= addr_r + 1;
                en <= '1';

                if addr_r = to_unsigned(IMG_WIDTH *2/4 + 2, 16) then
                    next_state <= W;
                else
                    next_state <= Continuous_R;
                end if;
                
                buf(r_p_y, r_p_x +3) <= dataR(31 downto 24);
                buf(r_p_y, r_p_x +2) <= dataR(23 downto 16);
                buf(r_p_y, r_p_x +1) <= dataR(15 downto 8);
                buf(r_p_y, r_p_x) <= dataR(7 downto 0);
                
                r_p_x := r_p_x +4;
                if r_p_x = IMG_WIDTH then
                    r_p_x := 0;
                    r_p_y := r_p_y+1;
                end if;
                
            when R =>
                next_addr_r <= addr_r + 1;
                if addr_r = to_unsigned(IMG_SIZE/4, 16) then  --x"6300" then
                    next_state <= F;
                else
                    addr <= std_logic_vector(addr_r);
                    en <= '1';
                    next_state <= W;
                end if;

            when W =>
                en <= '1';
                we <= '1';
                buf(r_p_y, r_p_x +3) <= dataR(31 downto 24);
                buf(r_p_y, r_p_x +2) <= dataR(23 downto 16);
                buf(r_p_y, r_p_x +1) <= dataR(15 downto 8);
                buf(r_p_y, r_p_x) <= dataR(7 downto 0);

                r_p_x := r_p_x +4;
                if r_p_x = IMG_WIDTH then
                    r_p_x := 0;
                    r_p_y := r_p_y+1;
                    if r_p_y = 3 then
                        r_p_y := 0;
                    end if;
                end if; 
                
                addr <= std_logic_vector(addr_w);
                next_addr_w <= addr_w + 1;
--                addr_w := addr_w + 1;
                dataW <=  (others=>'1');    --std_logic_vector("11111111111111111111111111111111" - data_var);
                next_state <= R;

            when F => 
                finish <= '1';
                next_state <= IDLE;
                
        end case; 
    end process;  
    

end rtl;
