----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2020 09:16:50 PM
-- Design Name: 
-- Module Name: gcd_data - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gcd_data is
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
end gcd_data;

architecture structural of gcd_data is
    component alu is
        generic (W:     natural := 16);						-- width of inputs.
        port (A, B:     in unsigned(W downto 1);			-- input operands.
              fn:       in std_logic_vector(1 downto 0); 	-- function.
              C:        out unsigned(W downto 1);			-- result.
              Z:        out std_logic;          			-- result = 0 flag.
              N:        out std_logic);         			-- result neg flag.
    end component;
    
    component reg is
        generic (N:     natural := 16);				-- width of inputs.
        port (clk:      in  std_logic;				-- clock signal.
              en:       in  std_logic;				-- enable signal.
              data_in:  in  unsigned(N downto 1);	-- input data.
              data_out: out unsigned(N downto 1));	-- output data.
    end component;
    
    component mux is
    generic (N:     natural := 16);				-- width of inputs and output.
        port (data_in1:  in  unsigned(N downto 1);	-- inputs.
              data_in2:  in unsigned(N downto 1);
              s       :  in std_logic;				-- select signal.
              data_out:  out  unsigned(N downto 1)	-- output.
              );
    end component;
    
    component buf is
        generic (N:     natural := 16);				-- width of inputs.
        port (data_in:  in  unsigned(N downto 1);	-- input.
              data_out: out unsigned(N downto 1));	-- output.
    end component;
    
    signal Y : unsigned(15 downto 0);
    signal C_int : unsigned(15 downto 0);
    signal ALU_in_A : unsigned(15 downto 0);
    signal ALU_in_B : unsigned(15 downto 0);
begin



input_mux : mux port map (data_in1 => Y, data_in2 => AB, s => ABorALU, data_out => C_int);

registerA : reg port map (clk => clk, en => LDA, data_in => C_int, data_out => ALU_in_A);

registerB : reg port map (clk => clk, en => LDB, data_in => C_int, data_out => ALU_in_B);

main_alu : alu port map (A => ALU_in_A, B => ALU_in_B, fn => FN, C => Y, Z => Z, N => N);

output_buffer : buf port map (data_in => C_int, data_out => C);


end structural;
