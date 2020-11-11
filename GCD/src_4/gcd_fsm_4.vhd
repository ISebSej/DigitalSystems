library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd_fsm is
  port (
    -- misc
    clk   : in std_logic;               -- The clock signal.
    reset : in  std_logic;              -- Reset the module.
    -- Handshake signals
    req   : in  std_logic;              -- Input operand / start computation.
    ack   : out std_logic;              -- Computation is complete.
    -- ALU results
    N     : in  std_logic;              -- Y[15] == 1 (negative result)
    Z     : in  std_logic;              -- Zero result
    -- Control signals
    FN    : out std_logic_vector(1 downto 0);   -- ALU control signal
    LDA   : out std_logic;              -- Open register A
    LDB   : out std_logic;              -- Open register B
    ABorALU   : out std_logic           -- Either input or continue computation
    );
end gcd_fsm;

architecture behavioural of gcd_fsm is

  type state_type is ( idle, receiveA, receiveB, waitB, calculate ); -- Input your own state names

  signal state, next_state : state_type;
  signal next_LDA : std_logic;
  signal next_LDB : std_logic;
  signal next_ABorALU : std_logic;
  signal next_ack : std_logic;
  signal next_FN : std_logic_vector(1 downto 0);
  

begin

    next_LDA <= '1' when state = receiveA else '1' when state = calculate and N = '0' else '0';
    ack <= '1' when state = receiveA else '1' when Z = '1' else '0';
    next_LDB <= '1' when state = receiveB else '1' when state = calculate and N = '1' else '0';
    next_ABorALU <= '1' when state = receiveA else '1' when state = receiveB else '0';
    next_FN <= Z & N when state = calculate else (others => '0');
    
  -- Combinatoriel logic

  cl : process (req,reset, Z, N)
  begin
    
    case state is
      when idle =>
          if req = '1' then -- press req to start and input A
               next_state <= receiveA;
          else
               next_state <= idle;
          end if;
          
      when receiveA =>
          next_state <= waitB;
          
      when waitB => -- wait for req to be released
          if req = '1' then
              next_state <= receiveB;
          else
              next_state <= waitB;
          end if ;
          
      when receiveB => -- press req to input value B
          if req = '1' then
              next_state <= calculate;
           else
              next_state <= receiveB;
           end if ;
          
      when calculate => 
          if Z = '1' then
            next_state <= idle;
          else
            next_state <= calculate;
          end if;
    end case;
  end process cl;

  -- Registers

  seq : process (clk, reset)
  begin

    if reset = '1' then
      -- wait handshake till incoming req signal
      state <= idle;
--      LDA <= '0';
--      LDB <= '0';
--      ABorALU <= '0';
--      FN <= (others => '0');
    elsif rising_edge(clk) then
      FN <= next_FN;
      LDA <= next_LDA;
      LDB <= next_LDB;
      ABorALU <= next_ABorALU;
      state <= next_state;
    end if ;

  end process seq;


end behavioural;