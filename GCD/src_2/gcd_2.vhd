-- -----------------------------------------------------------------------------
--
--  Title      :  FSMD implementation of GCD
--             :
--  Developers :  Jens SparsÃ¸, Rasmus Bo SÃ¸rensen and Mathias MÃ¸ller Bruhn
--           :
--  Purpose    :  This is a FSMD (finite state machine with datapath) 
--             :  implementation the GCD circuit
--             :
--  Revision   :  02203 fall 2019 v.5.0
--
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd is
  port (clk : in std_logic;             -- The clock signal.
    reset : in  std_logic;              -- Reset the module.
    req   : in  std_logic;              -- Input operand / start computation.
    AB    : in  unsigned(15 downto 0);  -- The two operands.
    ack   : out std_logic;              -- Computation is complete.
    C     : out unsigned(15 downto 0)); -- The result.
end gcd;

architecture fsmd of gcd is

  type state_type is ( idle, receiveA, waitB, receiveB, calc ); -- Input your own state names

  signal reg_a, next_reg_a, next_reg_b, reg_b : unsigned(15 downto 0);

  signal state, next_state : state_type;


begin

  -- Combinatoriel logic

  cl : process (req,ab,state,reg_a,reg_b,reset)
  begin
    
    -- reg_a <= next_reg_a;
    -- reg_b <= next_reg_b;
    
    case (state) is

      when idle =>
        ack <= '0';
        next_reg_a <= (others => '0');
        next_reg_b <= (others => '0');
        if req = '1' then
          next_state <= receiveA;
        else
          next_state <= idle;
        end if ; 

      when receiveA =>
        if req = '1' then
          next_reg_a <= ab;
          ack <= '1';
          next_state <= receiveA;
        else
          next_state <= waitB;
         end if ;

      when waitB => 
       if req = '0' then
          ack <= '0';
          next_state <= waitB;
        else
          next_state <= receiveB;
        end if ;

      when receiveB =>
          next_reg_b <= ab;
          next_state <= calc;

      when calc => 
        if reg_a /= reg_b then
          if reg_a > reg_b then
            next_reg_a <= reg_a - reg_b;
            next_state <= calc;
          else
            next_reg_b <= reg_b - reg_a;
            next_state <= calc;
          end if;
        else
            C <= reg_a;
            ack <= '1';
            next_state <= idle;
        end if ;


        
    end case;
  end process cl;

  -- Registers

  seq : process (clk, reset)
  begin

    if reset = '1' then
      state <= idle;
      reg_a <= (others => '0');
      reg_b <= (others => '0');
    elsif rising_edge(clk) then
      state <= next_state;
      reg_a <= next_reg_a;
      reg_b <= next_reg_b ;
    end if ;

  end process seq;


end fsmd;
