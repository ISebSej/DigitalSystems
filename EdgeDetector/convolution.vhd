
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity convoluter is
    port(   -- input pixel matrix
            s11,s21,s31,s41,s51,s61     : in  std_logic_vector(7 downto 0);
            s12,s22,s32,s42,s52,s62     : in  std_logic_vector(7 downto 0);
            s13,s23,s33,s43,s53,s63     : in  std_logic_vector(7 downto 0);
            -- output result
            res1, res2, res3, res4    : out byte_t
        );
end entity;

architecture structure of convoluter is

    -- Add addX component for computing Gx_pixel
    component addX is 
        port (
            pix1, pix2, pix3:  in  std_logic_vector(7 downto 0);	-- input.
            res: out signed	-- output.
        );
    end component;
    -- X computation step 1 
    signal accumX1, accumX2, accumX3, accumX4, accumX5, accumX6 : signed; -- Intermediate wire for X computation
    -- Y computation step 1
    signal accumY1, accumY2, accumY3, accumY4, accumY5 : signed;          -- Intermediate wire for Y computation top row
    signal accumY6, accumY7, accumY8, accumY9, accumYA : signed;          -- Intermediate wire for Y computation bottum row
    -- Y computation step 2
    signal accumY1T, accumY2T, accumY3T, accumY4T : signed;          -- Intermediate wire for Y computation top row
    signal accumY1B, accumY2B, accumY3B, accumY4B : signed;          -- Intermediate wire for Y computation bottum row    
    -- Gx and GY results
    signal Gx1, Gx2, Gx3, Gx4 : signed;
    signal Gy1, Gy2, Gy3, Gy4 : signed;
    -- D_pixel
    signal D1, D2, D3, D4 : signed;
    
    begin
    -- Gx_pixel
    ---- First accumilation
    adder1 : addX port map (pix1 => s11, pix2 => s12, pix3 => s13, res => accumX1);
    adder2 : addX port map (pix1 => s21, pix2 => s22, pix3 => s23, res => accumX2);
    adder3 : addX port map (pix1 => s31, pix2 => s32, pix3 => s33, res => accumX3);
    adder4 : addX port map (pix1 => s41, pix2 => s42, pix3 => s43, res => accumX4);
    adder5 : addX port map (pix1 => s51, pix2 => s52, pix3 => s53, res => accumX5);
    adder6 : addX port map (pix1 => s61, pix2 => s62, pix3 => s63, res => accumX6);
    ---- Addition and Substraction
    
    Gx1 <= accumX1 - accumX3;
    Gx2 <= accumX2 - accumX4;
    Gx3 <= accumX3 - accumX5;
    Gx4 <= accumX4 - accumX6;
    
    -- Gy_pixel
    ---- Step 1
    ------ Top row
    accumY1 <= signed(s11) + signed(s21);
    accumY2 <= signed(s21) + signed(s31);
    accumY3 <= signed(s31) + signed(s41);
    accumY4 <= signed(s41) + signed(s51);
    accumY5 <= signed(s51) + signed(s61);
    
    ------ Bottom row
    accumY6 <= signed(s13) + signed(s23);
    accumY7 <= signed(s23) + signed(s33);
    accumY8 <= signed(s33) + signed(s43);
    accumY9 <= signed(s43) + signed(s53);
    accumYA <= signed(s53) + signed(s63);
    
    ---- Step 2
    ------ Top Row
    accumY1T <= accumY1 + accumY2;
    accumY2T <= accumY2 + accumY3;
    accumY3T <= accumY3 + accumY4;
    accumY4T <= accumY4 + accumY5;
    
    ------ Bottom Row
    accumY1B <= accumY6 + accumY7;
    accumY2B <= accumY7 + accumY8;
    accumY3B <= accumY8 + accumY9;
    accumY4B <= accumY9 + accumYA;   
    
    ---- Gy_pixel Calculate
    Gy1 <= accumY1B - accumY1T;
    Gy2 <= accumY2B - accumY2T;
    Gy3 <= accumY3B - accumY3T;
    Gy4 <= accumY4B - accumY4T;
    
   -- Final result calculation
   D1 <= abs(Gy1) + abs(Gx1);
   D2 <= abs(Gy2) + abs(Gx2);
   D3 <= abs(Gy3) + abs(Gx3);
   D4 <= abs(Gy4) + abs(Gx4);
   
   -- Return output
   res1 <= byte_t(D1);
   res2 <= byte_t(D2);
   res3 <= byte_t(D3);
   res4 <= byte_t(D4);

end structure;

------------------------------------
--Block made to perform the kernel calculation of a signle column of the input vector
--It is required to finish the Gx calculation. The output result can be used either positive or negative

--It takes in the three pixels in a column e.g. s11, a12, s12 and returns s11+ 2* s12 + s13
--------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addX is
    port (
        pix1, pix2, pix3:  in  std_logic_vector(7 downto 0);	-- input.
        res: out unsigned	-- output.
        );
end addX;

architecture behaviour of addX is
    signal add1, add2 : unsigned;
begin
    add1 <= unsigned(pix1) + unsigned(pix2);
    add1 <= unsigned(pix2) + unsigned(pix3); 
    res <= add1 + add2;
end behaviour;



