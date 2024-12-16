with URandProbeInt, Direct_IO, Ada.Text_IO, Ada.Unchecked_Conversion, Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

procedure Usehashtable is

   function chartoint is new ada.Unchecked_Conversion(Character,Long_Integer);
   function stringtoint is new ada.Unchecked_Conversion(String,Long_Integer);

   type str16 is array(1..16) of Character;
   mt: str16 := "                ";
   E: String (1..16);
   F, G: String (1..2);
   H: String (1..6);

   type charRec is record
      charStr: str16 := mt;
   end record;

   type hashTable is record
      key: str16 := mt;
      hashAd: Long_Integer := 0;
      probes: Long_Integer := 0;
   end record;

   package IIO is new Ada.Text_IO.Integer_IO(Integer); use IIO;
   package LIIO is new Ada.Text_IO.Integer_IO(Long_Integer); use LIIO;
   package FIO is new Ada.Text_IO.Float_IO(Float); use FIO;
   package IOD is new Direct_IO(charRec); use IOD;
   package DIO is new Direct_IO(hashTable); use DIO;

   cnt, HA, randInt: DIO.Count := 0;
   wordFile: IOD.File_Type;
   hashFile, dataFile: DIO.File_Type;
   charRec1: charRec;
   hashRec, tempRec: hashTable;
   val, linExPr, ranExPro, flVal, nlVal: float;
   sum, A, B, C, D, I, hashA, min1, max1, ave1, min2, max2, ave2, min3, max3, ave3, tempPro1, tempPro2, probe: Long_Integer;
   pInt: Integer;
   tempHashArray: array(1..75) of hashTable; --used for linear/random probe
   TS: Integer := 7; -- 2^^7 = 128, whatever is above 75, the table size for the datafile, we throw out.

   package RandomOffset is new URandProbeInt(TS); use RandomOffset;

begin

   InitialRandInteger;

   IOD.open(wordFile, Inout_File, "Words200D16.txt"); --opening the reading the sequential file
   DIO.create(hashFile, Inout_File, "HashFile.txt"); --creating the hash file

   Ada.Text_IO.Put("List of all 75 records: "); Ada.Text_IO.New_Line;

   for pt in IOD.Positive_Count range 1..100 loop

      IOD.read(wordFile, charRec1, pt);

      hashRec.key := charRec1.charStr;

      cnt := cnt + 1;


      DIO.write(hashFile, hashRec, cnt);

   end loop;

   DIO.close(hashFile); --closing the writing of the hashfile
   IOD.close(wordFile); --closing the reading of the wordfile

   DIO.open(hashFile, Inout_File, "HashFile.txt"); --opening the hash file
   DIO.create(dataFile, Inout_File, "Datafile.txt"); --creating the data file


   for pt in DIO.Positive_Count range 1..75 loop

      DIO.read(hashFile, hashRec, pt);

      --//Dr. Burris' hash function

      --A := chartoint(hashRec.key(1));
      --B := chartoint(hashRec.key(5));
      --C := chartoint(hashRec.key(7));
      --D := chartoint(hashRec.key(11));

      --sum := abs(A / (128 * 128)) + abs(((B + C) * 5) / (2**9)) + abs(D / 128);
      --HA := DIO.Count(Sum);
      --hashRec.hashAd := Long_Integer(pt);
      --hashA := sum;

      --//my hash function

      E := String(hashRec.key);
      F := E(1..2);
      G := E(2..3);
      H := E(1..6);
      H(5..6) := G;
      H(4..5) := G;
      H(2..3) := F; --H(112233)
      I := stringtoint(H);

      sum := abs(I mod 76);
      HA := DIO.Count(sum);
      hashRec.hashAd := Long_Integer(pt);
      hashA := sum;

      --//linear probe

      --while(hashRec.probes <= (2**TS)) loop
      --   if (HA = 0) then
      --      HA := HA + 1;
      --      hashRec.probes := hashRec.probes + 1;
      --   elsif (HA = 76) then
      --      HA := 1;
      --      hashRec.probes := hashRec.probes + 1;
      --   elsif (tempHashArray(integer(HA)).key = mt) then
      --      tempHashArray(Integer(HA)).key := hashRec.key;
      --      hashRec.probes := hashRec.probes + 1;
      --      write(dataFile, hashRec, HA);
      --      hashRec.probes := 129;
      --   else
      --      HA := HA + 1;
      --      hashRec.probes := hashRec.probes + 1;
      --   end if;
      --end loop;


      --//Random probe

      randInt := DIO.Count(UniqueRandInteger);
      HA := HA + randInt;

      while (hashRec.probes <= (2**TS)) loop
         if (randInt > 74) then
            HA := HA - randInt;
            randInt := DIO.Count(UniqueRandInteger);
            HA := HA + randInt;
         elsif (HA > 75) then
            HA := HA - 75;
         elsif (tempHashArray(integer(HA)).key = mt) then
            tempHashArray(integer(HA)).key := hashRec.key;
            hashRec.probes := hashRec.probes + 1;
            Write(dataFile, hashRec, HA);
            hashRec.probes := 2**TS + 1;
         elsif (randInt = 1) then
            InitialRandInteger;
            randInt := DIO.Count(UniqueRandInteger);
            HA := HA + randInt;
         else
            randInt := DIO.Count(UniqueRandInteger);
            HA := HA + randInt;
            hashRec.probes := hashRec.probes + 1;
         end if;
      end loop;

      pInt := Integer(pt);
      IIO.Put(pInt,2); Ada.Text_IO.Put(" ");

      for j in 1..16 loop
         Ada.Text_IO.Put(hashRec.key(j));
      end loop;

      Ada.Text_IO.Put(" Initial HA: "); LIIO.Put(hashRec.hashAd, 2); Ada.Text_IO.Put(" | "); Ada.Text_IO.Put(" HA after Hash Function: "); LIIO.Put(hashA, 2); Ada.Text_IO.Put(" | ");
      Ada.Text_IO.New_Line;

   end loop;

   DIO.close(dataFile); --closing the writing of the datafile
   DIO.close(hashFile); --closing the reading of the hashfile

   DIO.open(dataFile, Inout_File, "Datafile.txt"); --opening the reading for the datafile

   Ada.Text_IO.Put("List of all 75 records: "); Ada.Text_IO.New_Line;
   for pt in DIO.Positive_Count range 1..75 loop

      DIO.read(dataFile, hashRec, pt);

      if (hashRec.hashAd < 26) then
         ave1 := ave1 + hashRec.probes;
         tempPro1 := hashRec.probes;

         if (pt = 1) then
            min1 := hashRec.probes;
            max1 := hashRec.probes;
         else
            null;
         end if;

         if (min1 > tempPro1) then
            min1 := tempPro1;
         else
            null;
         end if;

         if (max1 < tempPro1) then
            max1 := tempPro1;
         else
            null;
         end if;
      end if;

      if (hashRec.hashAd > 50) then
         ave2 := ave2 + hashRec.probes;
         tempPro2 := hashRec.probes;

         if (pt = 1) then
            min2 := hashRec.probes;
            max2 := hashRec.probes;
         else
            null;
         end if;

         if (min2 > tempPro2) then
            min2 := tempPro2;
         else
            null;
         end if;

         if (max2 < tempPro2) then
            max2 := tempPro2;
         else
            null;
         end if;
      end if;


      pInt := Integer(pt);
      IIO.Put(pInt,2); Ada.Text_IO.Put(" ");

      for j in 1..16 loop
         Ada.Text_IO.Put(hashRec.key(j));
      end loop;

      Ada.Text_IO.Put(" Initial HA: "); LIIO.Put(hashRec.hashAd, 2); Ada.Text_IO.Put(" | ");Ada.Text_IO.Put(" Probes: "); LIIO.Put(hashRec.probes, 2);
      Ada.Text_IO.New_Line;

      probe := hashRec.probes;
      ave3 := ave3 + probe;

      if (pt = 1) then
         min3 := probe;
         max3 := probe;
      else
         null;
      end if;

      if (min3 > probe) then
         min3 := probe;
      else
         null;
      end if;

      if (max3 < probe) then
         max3 := probe;
      else
         null;
      end if;

   end loop;

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("First 25 records: Min, Max, and Average probes"); Ada.Text_IO.New_Line; Ada.Text_IO.New_Line;

   Ada.Text_IO.Put("Minimum amount of probes for the first 25 records is: "); LIIO.Put(min1, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Maximum amount of probes for the first 25 records is: "); LIIO.Put(max1, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Average amount of probes for the first 25 records is: "); LIIO.Put(ave1 / 25, 2); Ada.Text_IO.New_Line; Ada.Text_IO.New_Line;

   Ada.Text_IO.Put("Last 25 records: Min, Max, and Average probes"); Ada.Text_IO.New_Line; Ada.Text_IO.New_Line;

      Ada.Text_IO.Put("Minimum amount of probes for the last 25 records is: "); LIIO.Put(min2, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Maximum amount of probes for the last 25 records is: "); LIIO.Put(max2, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Average amount of probes for the last 25 records is: "); LIIO.Put(ave2 / 25, 2); Ada.Text_IO.New_Line; Ada.Text_IO.New_Line;

   val := 25.0 / 75.0;
   linExPr := ((1.0 - (val / 2.0)) / (1.0 - val));
   flVal := -(1.0 / val);
   nlVal := log(1.0 - val);
   ranExPro := (flVal * nlVal);

   Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Theoretical Expected amount of probes for linear: "); FIO.Put(linExPr ,1, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Theoretical Expected amount of probes for random: "); FIO.Put(ranExPro, 1, 2); Ada.Text_IO.New_Line; Ada.Text_IO.New_Line;

   Ada.Text_IO.Put("Minimum amount of probes for all records is: "); LIIO.Put(min3, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Maximum amount of probes for all records is: "); LIIO.Put(max3, 2); Ada.Text_IO.New_Line;
   Ada.Text_IO.Put("Average amount of probes for all records is: "); LIIO.Put(ave3 / 75, 2); Ada.Text_IO.New_Line; Ada.Text_IO.New_Line;

   val := 75.0 / 75.0;
   linExPr := ((1.0 - (val / 2.0)) / (1.0 - val));

   Ada.Text_IO.Put("Theoretical Expected amount of probes for linear: "); FIO.Put(linExPr ,1, 2); Ada.Text_IO.New_Line;

   DIO.close(dataFile); --closing the reading of the datafile

end Usehashtable;
