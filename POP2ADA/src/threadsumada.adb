with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Generic_Elementary_Functions;

procedure Find_Minimum is
   -- Constants for the array size and number of threads.
   dim : constant Integer := 100000;
   thread_num : constant Integer := 2;

   -- The array to be processed.
   arr : array(1..dim) of Integer;

   -- Initialize the array with sequential values, with one random negative number.
   procedure Init_Arr is
      Random_Number : constant Integer := 100; -- Index for the negative value.
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;
      arr(Random_Number) := -12345; -- Setting a negative number at a random index.
   end Init_Arr;

   -- Task for finding minimum in a portion of the array.
   task type Min_Finder_Thread is
      entry Start(Start_Index, Finish_Index : in Integer);
   end Min_Finder_Thread;

   -- Shared data structure for synchronizing the minimum values.
   protected Min_Manager is
      procedure Set_Min_Value(Value, Index : in Integer);
      entry Get_Minimum(Min_Value : out Integer; Min_Index : out Integer);
   private
      Min_Value : Integer := Integer'Last;
      Min_Index : Integer := -1;
      Tasks_Count : Integer := 0;
   end Min_Manager;

   -- Implementation of Min_Manager.
   protected body Min_Manager is
      procedure Set_Min_Value(Value, Index : in Integer) is
      begin
         if Value < Min_Value then
            Min_Value := Value;
            Min_Index := Index;
         end if;
         Tasks_Count := Tasks_Count + 1;
      end Set_Min_Value;

      entry Get_Minimum(Min_Value : out Integer; Min_Index : out Integer) when Tasks_Count = thread_num is
      begin
         Min_Value := Min_Value;
         Min_Index := Min_Index;
      end Get_Minimum;
   end Min_Manager;

   -- Implementation of Min_Finder_Thread.
   task body Min_Finder_Thread is
      Start_Index, Finish_Index : Integer;
   begin
      accept Start(Start_Index, Finish_Index : in Integer) do
         Min_Finder_Thread.Start_Index := Start_Index;
         Min_Finder_Thread.Finish_Index := Finish_Index;
      end Start;

      -- Find minimum in the assigned portion.
      declare
         Local_Min : Integer := arr(Start_Index);
         Local_Min_Index : Integer := Start_Index;
      begin
         for i in Start_Index..Finish_Index loop
            if arr(i) < Local_Min then
               Local_Min := arr(i);
               Local_Min_Index := i;
            end if;
         end loop;

         -- Set the local minimum to the shared manager.
         Min_Manager.Set_Min_Value(Local_Min, Local_Min_Index);
      end;
   end Min_Finder_Thread;

   -- Main program logic to start threads and get the minimum value.
   Min_Finder : array(1..thread_num) of Min_Finder_Thread;
   Min_Value : Integer;
   Min_Index : Integer;

begin
   Init_Arr;

   -- Start threads to find minimum in parts of the array.
   Min_Finder(1).Start(1, dim / thread_num);
   Min_Finder(2).Start(dim / thread_num + 1, dim);

   -- Get the minimum value from the manager.
   Min_Manager.Get_Minimum(Min_Value, Min_Index);

   -- Output the minimum value and its index.
   Put_Line("Minimum value: " & Integer'Image(Min_Value));
   Put_Line("Index of minimum value: " & Integer'Image(Min_Index));
end Find_Minimum;
