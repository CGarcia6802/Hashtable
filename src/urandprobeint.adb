package body URandProbeInt is

   R: Integer := 1;
   
   procedure InitialRandInteger is
   begin
      R := 1;
   end InitialRandInteger;
   
   function UniqueRandInteger return Integer is
   begin
      R := (5 * R) Mod (2 ** (NumBits + 2));
      return R / 4;
   end UniqueRandInteger;

end URandProbeInt;
