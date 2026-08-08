-- src/mark_and_sweep.adb
package body Mark_And_Sweep is

   --------------------------------------------------
   -- Core Operations
   --------------------------------------------------
   procedure Allocate (Heap : in out Heap_Array; Idx : out Object_Index) is
   begin
      for I in Heap'Range loop
         if not Heap(I).Is_Allocated then
            Heap(I).Is_Allocated := True;
            Heap(I).Marked       := False;
            Heap(I).Color        := White;
            Heap(I).Refs         := (others => Null_Ptr);
            Idx := I;
            return;
         end if;
      end loop;
      raise Out_Of_Memory;
   end Allocate;

   procedure Add_Reference (Heap : in out Heap_Array; From, To : Object_Index; Slot : Positive) is
   begin
      if From = Null_Ptr or else not Heap(From).Is_Allocated then
         raise Invalid_Reference;
      end if;
      if Slot > Max_Refs_Per_Object then
         raise Invalid_Reference;
      end if;
      Heap(From).Refs(Slot) := To;
   end Add_Reference;

   function Count_Allocated (Heap : Heap_Array) return Natural is
      Count : Natural := 0;
   begin
      for I in Heap'Range loop
         if Heap(I).Is_Allocated then
            Count := Count + 1;
         end if;
      end loop;
      return Count;
   end Count_Allocated;

   procedure Reset_Heap (Heap : in out Heap_Array) is
   begin
      for I in Heap'Range loop
         Heap(I).Is_Allocated := False;
         Heap(I).Marked       := False;
         Heap(I).Color        := White;
         Heap(I).Refs         := (others => Null_Ptr);
      end loop;
   end Reset_Heap;

   -- Helper for standard sweeping phase
   procedure Standard_Sweep (Heap : in out Heap_Array) is
   begin
      for I in Heap'Range loop
         if Heap(I).Is_Allocated then
            if Heap(I).Marked then
               Heap(I).Marked := False; -- Keep and unmark
            else
               Heap(I).Is_Allocated := False; -- Reclaim
            end if;
         end if;
      end loop;
   end Standard_Sweep;


   --------------------------------------------------
   -- Variant 1: Recursive Mark and Sweep
   --------------------------------------------------
   procedure Recursive_Mark_And_Sweep (Heap : in out Heap_Array; Roots : Root_Set) is
      procedure Mark (Idx : Object_Index) is
      begin
         if Idx = Null_Ptr then return; end if;
         if not Heap(Idx).Is_Allocated then return; end if;
         if Heap(Idx).Marked then return; end if; -- Prevent infinite loops on cycles

         Heap(Idx).Marked := True;
         for I in 1 .. Max_Refs_Per_Object loop
            Mark(Heap(Idx).Refs(I));
         end loop;
      end Mark;
   begin
      -- Phase 1: Mark
      for R of Roots loop
         Mark(R);
      end loop;
      -- Phase 2: Sweep
      Standard_Sweep(Heap);
   end Recursive_Mark_And_Sweep;


   --------------------------------------------------
   -- Variant 2: Iterative Mark and Sweep
   --------------------------------------------------
   procedure Iterative_Mark_And_Sweep (Heap : in out Heap_Array; Roots : Root_Set) is
      type Stack_Array is array (1 .. Max_Objects) of Object_Index;
      Stack : Stack_Array;
      Top   : Natural := 0;
      Curr  : Object_Index;

      procedure Push (Idx : Object_Index) is
      begin
         if Idx /= Null_Ptr and then Heap(Idx).Is_Allocated and then not Heap(Idx).Marked then
            Top := Top + 1;
            Stack(Top) := Idx;
         end if;
      end Push;
   begin
      -- Phase 1: Mark
      for R of Roots loop
         Push(R);
      end loop;

      while Top > 0 loop
         Curr := Stack(Top);
         Top := Top - 1;

         if not Heap(Curr).Marked then
            Heap(Curr).Marked := True;
            for I in 1 .. Max_Refs_Per_Object loop
               Push(Heap(Curr).Refs(I));
            end loop;
         end if;
      end loop;

      -- Phase 2: Sweep
      Standard_Sweep(Heap);
   end Iterative_Mark_And_Sweep;


   --------------------------------------------------
   -- Variant 3: Tri-color Mark and Sweep
   --------------------------------------------------
   procedure Tricolor_Mark_And_Sweep (Heap : in out Heap_Array; Roots : Root_Set) is
      type Gray_Stack is array (1 .. Max_Objects) of Object_Index;
      Grays : Gray_Stack;
      Top   : Natural := 0;
      Curr  : Object_Index;
      Child : Object_Index;
   begin
      -- Initialize all to White (handled by sweep usually, but we ensure it here)
      for I in Heap'Range loop
         Heap(I).Color := White;
      end loop;

      -- Mark Roots as Gray
      for R of Roots loop
         if R /= Null_Ptr and then Heap(R).Is_Allocated then
            Heap(R).Color := Gray;
            Top := Top + 1;
            Grays(Top) := R;
         end if;
      end loop;

      -- Process Grays
      while Top > 0 loop
         Curr := Grays(Top);
         Top := Top - 1;

         -- Move children to Gray if they are White
         for I in 1 .. Max_Refs_Per_Object loop
            Child := Heap(Curr).Refs(I);
            if Child /= Null_Ptr and then Heap(Child).Is_Allocated then
               if Heap(Child).Color = White then
                  Heap(Child).Color := Gray;
                  Top := Top + 1;
                  Grays(Top) := Child;
               end if;
            end if;
         end loop;
         
         -- Blacken the current object
         Heap(Curr).Color := Black;
      end loop;

      -- Sweep Phase (Custom for Tricolor)
      for I in Heap'Range loop
         if Heap(I).Is_Allocated then
            if Heap(I).Color = White then
               Heap(I).Is_Allocated := False; -- Reclaim
            else
               Heap(I).Color := White; -- Reset for next GC cycle
            end if;
         end if;
      end loop;
   end Tricolor_Mark_And_Sweep;

end Mark_And_Sweep;
