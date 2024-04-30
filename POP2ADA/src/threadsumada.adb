with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure ThreadSumAda is

   Dim : constant Integer := 100000;
   Thread_Num : constant Integer := 4;

   Arr : array(1..Dim) of Integer;

   procedure Init_Arr is
   begin
      for I in 1..Dim loop
         Arr(I) := -1;
      end loop;
   end Init_Arr;

   function Part_Sum(Start_Index, Finish_Index : in Integer) return Long_Long_Integer is
      Sum : Long_Long_Integer := 0;
   begin
      for I in Start_Index..Finish_Index loop
         Sum := Sum + Long_Long_Integer(Arr(I));
      end loop;
      return Sum;
   end Part_Sum;

   task type Starter_Thread is
      entry Start(Start_Index, Finish_Index : in Integer);
   end Starter_Thread;

   protected Part_Manager is
      procedure Set_Part_Sum(Sum : in Long_Long_Integer);
      entry Get_Min_Value(Min_Value : out Long_Long_Integer; Min_Index : out Integer);
   private
      Tasks_Count : Integer := 0;
      Min_Value : Long_Long_Integer := Long_Long_Integer'Last;
      Min_Index : Integer := 0;
   end Part_Manager;

   protected body Part_Manager is
      procedure Set_Part_Sum(Sum : in Long_Long_Integer) is
      begin
         if Sum < Min_Value then
            Min_Value := Sum;
            Min_Index := Tasks_Count;
         end if;
         Tasks_Count := Tasks_Count + 1;
      end Set_Part_Sum;

      entry Get_Min_Value(Min_Value : out Long_Long_Integer; Min_Index : out Integer) when Tasks_Count = Thread_Num is
      begin
         Min_Value := Part_Manager.Min_Value;
         Min_Index := Part_Manager.Min_Index;
      end Get_Min_Value;

   end Part_Manager;

   task body Starter_Thread is
      Sum : Long_Long_Integer := 0;
      Start_Index, Finish_Index : Integer;
   begin
      accept Start(Start_Index, Finish_Index : in Integer) do
         Starter_Thread.Start_Index := Start_Index;
         Starter_Thread.Finish_Index := Finish_Index;
      end Start;
      Sum := Part_Sum(Start_Index  => Start_Index,
                      Finish_Index => Finish_Index);
      Part_Manager.Set_Part_Sum(Sum);
   end Starter_Thread;

   function Parallel_Sum return Long_Long_Integer is
      Sum : Long_Long_Integer := 0;
      Threads : array(1..Thread_Num) of Starter_Thread;
   begin
      for I in 1..Thread_Num loop
         Threads(I).Start(1 + (I-1)*Dim/Thread_Num, I*Dim/Thread_Num);
      end loop;
      declare
         Min_Index : Integer;
      begin
         Part_Manager.Get_Min_Value(Sum, Min_Index);
         return Sum;
      end;
   end Parallel_Sum;

   procedure Print_Result(Min_Value : Long_Long_Integer; Min_Index : Integer) is
   begin
      Put_Line("Min value: " & Long_Long_Integer'Image(Min_Value) & " | Index: " & Integer'Image(Min_Index));
   end Print_Result;

begin
   Init_Arr;
   Print_Result(Parallel_Sum, 0);
end ThreadSumAda;
