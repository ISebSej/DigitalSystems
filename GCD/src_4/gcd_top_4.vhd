-- -----------------------------------------------------------------------------
--
--  Title      :  Implementation of the GCD with debouncer
--             :
--  Developers :  Jens SparsÃƒÂ¸, Rasmus Bo SÃƒÂ¸rensen and Mathias MÃƒÂ¸ller Bruhn
--          :
--  Purpose    :  This design instantiates a debouncer and an implementation of GCD
--             :
--  Revision   :  02203 fall 2019 v.6.0
--
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gcd_top is
  port (clk : in std_logic;             -- the clock signal.
    reset : in  std_logic;              -- reset the module.
    req   : in  std_logic;              -- input operand / start computation.
    AB    : in  unsigned(15 downto 0);  -- bus for a and b operands.
    ack   : out std_logic;              -- last input received / computation is complete.
    C     : out unsigned(15 downto 0)); -- the result.
end gcd_top;


architecture structure of gcd_top is

  component debounce
    port (
      clk : in std_logic;
      reset    : in  std_logic;
      sw       : in  std_logic;
      db_level : out std_logic;
      db_tick  : out std_logic
    );
  end component;

  component gcd_fsm is
    port ( clk   : in std_logic;               -- The clock signal.
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
        ABorALU   : out std_logic);
  end component;

component gcd_data is
    port ( clk   : in std_logic;               -- The clock signal.
        -- data paths
        AB    : in unsigned(15 downto 0);
        C     : out unsigned(15 downto 0);
        -- ALU results
        N     : out  std_logic;              -- Y[15] == 1 (negative result)
        Z     : out  std_logic;              -- Zero result
        -- Control signals
        FN    : in std_logic_vector(1 downto 0);   -- ALU control signal
        LDA   : in std_logic;              -- Open register A
        LDB   : in std_logic;              -- Open register B
        ABorALU   : in std_logic);
  end component;
  
  signal db_req : std_logic;
  -- intermediate wires FSM out
  signal fsm_FN : std_logic_vector(1 downto 0);
  signal fsm_LDA : std_logic;
  signal fsm_LDB : std_logic;
  signal fsm_ABorALU : std_logic;
  -- intermediate wires datapath out
  signal data_N : std_logic;
  signal data_Z : std_logic;
  
begin

    debouncer : debounce port map (
        clk => clk, 
        reset => reset, 
        sw => req, 
        db_level => db_req, 
        db_tick => open
    );
    
    fsm : gcd_fsm port map (
        clk => clk, 
        reset => reset, 
        req => db_req, 
        ack => ack,
        N => data_N,
        Z => data_Z,
        FN => fsm_FN,
        LDA => fsm_LDA,
        LDB => fsm_LDB,
        ABorALU => fsm_ABorALU
    );
    
    datapath : gcd_data port map (
        clk => clk, 
        AB => AB,
        C => C,
        N => data_N,
        Z => data_Z,
        FN => fsm_FN,
        LDA => fsm_LDA,
        LDB => fsm_LDB,
        ABorALU => fsm_ABorALU
     ); 

end structure;
