-- src/mark_and_sweep.ads
package Mark_And_Sweep is

   -- Strong typing for our custom memory management simulation
   Max_Objects : constant := 1000;
   type Object_Index is new Integer range 0 .. Max_Objects;
   Null_Ptr : constant Object_Index := 0;

   -- We allow up to 2 references per object to simulate a binary tree / graph
   Max_Refs_Per_Object : constant := 2;
   type Reference_Array is array (1 .. Max_Refs_Per_Object) of Object_Index;

   -- Colors for the Tri-color variant
   type Color_Type is (White, Gray, Black);

   -- Custom exception for edge cases
   Out_Of_Memory : exception;
   Invalid_Reference : exception;

   -- The object structure
   type GC_Object is record
      Is_Allocated : Boolean         := False;
      Marked       : Boolean         := False; -- Used for Naive and Iterative
      Color        : Color_Type      := White; -- Used for Tri-color
      Refs         : Reference_Array := (others => Null_Ptr);
   end record;

   -- The Heap and Roots representations
   type Heap_Array is array (Object_Index range 1 .. Max_Objects) of GC_Object;
   type Root_Set is array (Positive range <>) of Object_Index;

   -- Core Operations
   procedure Allocate (Heap : in out Heap_Array; Idx : out Object_Index);
   procedure Add_Reference (Heap : in out Heap_Array; From, To : Object_Index; Slot : Positive);
   function Count_Allocated (Heap : Heap_Array) return Natural;
   procedure Reset_Heap (Heap : in out Heap_Array);

   -- ==========================================
   -- ALGORITHM VARIANTS
   -- ==========================================

   -- Variant 1: Naive Recursive Mark and Sweep (Depth First)
   procedure Recursive_Mark_And_Sweep (Heap : in out Heap_Array; Roots : Root_Set);

   -- Variant 2: Iterative Mark and Sweep (Explicit Stack, prevents stack overflow)
   procedure Iterative_Mark_And_Sweep (Heap : in out Heap_Array; Roots : Root_Set);

   -- Variant 3: Tri-color Mark and Sweep (Dijkstra's variant)
   procedure Tricolor_Mark_And_Sweep (Heap : in out Heap_Array; Roots : Root_Set);

end Mark_And_Sweep;
