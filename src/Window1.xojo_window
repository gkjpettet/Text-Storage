#tag Window
Begin Window Window1
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF00
   Composite       =   False
   DefaultLocation =   0
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   Height          =   400
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   1344585727
   MenuBarVisible  =   True
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   True
   Title           =   "Untitled"
   Type            =   0
   Visible         =   True
   Width           =   600
End
#tag EndWindow

#tag WindowCode
	#tag Event
		Sub Open()
		  RunTests
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub RunTests()
		  Var insertAtFixedPosition As Dictionary = TestInsertAtFixedPosition
		  Var insertAtRandomLocation As Dictionary = TestInsertAtRandomLocation
		  Var insertAtStart As Dictionary = TestInsertAtStart
		  Var replaceAtRandomPosition As Dictionary = TestReplaceAtRandomPosition
		  Var getStringAt As Dictionary = TestGetStringAt
		  
		  // Create a report.
		  Var report() As String
		  report.add("Inserting at a fixed position (ms)")
		  report.add("----------------------------------")
		  report.Add("GapBuffer:     " + insertAtFixedPosition.Value("GapBuffer").StringValue)
		  report.Add("ArrayStorage:  " + insertAtFixedPosition.Value("Array").StringValue)
		  report.Add("StringStorage: " + insertAtFixedPosition.Value("String").StringValue)
		  report.Add(EndOfLine)
		  
		  report.add("Inserting at a random location (ms)")
		  report.add("-----------------------------------")
		  report.Add("GapBuffer:     " + insertAtRandomLocation.Value("GapBuffer").StringValue)
		  report.Add("ArrayStorage:  " + insertAtRandomLocation.Value("Array").StringValue)
		  report.Add("StringStorage: " + insertAtRandomLocation.Value("String").StringValue)
		  report.Add(EndOfLine)
		  
		  report.add("Inserting at the start (ms)")
		  report.add("---------------------------")
		  report.Add("GapBuffer:     " + insertAtStart.Value("GapBuffer").StringValue)
		  report.Add("ArrayStorage:  " + insertAtStart.Value("Array").StringValue)
		  report.Add("StringStorage: " + insertAtStart.Value("String").StringValue)
		  report.Add(EndOfLine)
		  
		  report.add("Replace text at a random position (ms)")
		  report.add("--------------------------------------")
		  report.Add("GapBuffer:     " + replaceAtRandomPosition.Value("GapBuffer").StringValue)
		  report.Add("ArrayStorage:  " + replaceAtRandomPosition.Value("Array").StringValue)
		  report.Add("StringStorage: " + replaceAtRandomPosition.Value("String").StringValue)
		  report.Add(EndOfLine)
		  
		  report.add("Retrieve a random segment of text (ms)")
		  report.add("--------------------------------------")
		  report.Add("GapBuffer:     " + getStringAt.Value("GapBuffer").StringValue)
		  report.Add("ArrayStorage:  " + getStringAt.Value("Array").StringValue)
		  report.Add("StringStorage: " + getStringAt.Value("String").StringValue)
		  report.Add(EndOfLine)
		  
		  Var tout As TextOutputStream = TextOutputStream.Create(SpecialFolder.Desktop.Child("test.txt"))
		  tout.Write(String.FromArray(report, EndOfLine))
		  tout.Close
		  
		  Quit
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TestGetStringAt() As Dictionary
		  ///
		  ' Tests getting strings from random locations in the buffer.
		  '
		  ' - Returns a dictionary containing the results of the tests.
		  '
		  ' - Notes:
		  ' Starts with an existing store of characters.
		  ///
		  
		  Const storeSize = 20000
		  Const iterations = 50000
		  Const char = "a"
		  Const maxRetrievalLength = 15
		  Var r As Random = System.Random
		  Var iMax As Integer = iterations - 1
		  Var cursorPos As Integer = 400
		  Var initialStoreSizeMax As Integer = storeSize - 1
		  
		  // ====================
		  // Test GapBuffer.
		  // ====================
		  Var gb As New GapBuffer
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    gb.Insert(0, "b")
		  Next i
		  
		  // Now retrieve a random selection of text.
		  Var startGB As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    // Get the start position of the string to retrieve.
		    Var index As Integer = r.InRange(0, gb.Length - maxRetrievalLength)
		    // Get the length of the string to retrieve.
		    Var length As Integer = r.InRange(1, maxRetrievalLength)
		    // Get the selection.
		    Call gb.GetStringAt(index, length)
		  Next i
		  Var totalGB As Integer = (System.Microseconds - startGB) / 1000
		  
		  // =========================
		  // Test using array storage
		  // =========================
		  Var a As New ArrayStorage
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    a.Insert(0, "b")
		  Next i
		  
		  // Now retrieve a random selection of text.
		  Var starta As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    // Get the start position of the string to retrieve.
		    Var index As Integer = r.InRange(0, a.Length - maxRetrievalLength)
		    // Get the length of the string to retrieve.
		    Var length As Integer = r.InRange(1, maxRetrievalLength)
		    // Get the selection.
		    Call a.GetStringAt(index, length)
		  Next i
		  Var totala As Integer = (System.Microseconds - starta) / 1000
		  
		  // =========================
		  // Test using string storage
		  // =========================
		  Var s As New StringStorage
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    s.Insert(0, "b")
		  Next i
		  
		  // Now retrieve a random selection of text.
		  Var starts As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    // Get the start position of the string to retrieve.
		    Var index As Integer = r.InRange(0, s.Length - maxRetrievalLength)
		    // Get the length of the string to retrieve.
		    Var length As Integer = r.InRange(1, maxRetrievalLength)
		    // Get the selection.
		    Call s.GetStringAt(index, length)
		  Next i
		  Var totals As Integer = (System.Microseconds - starts) / 1000
		  
		  Return New Dictionary("GapBuffer" : totalGB, "Array" : totala, "String" : totals)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TestInsertAtFixedPosition() As Dictionary
		  ///
		  ' Tests inserting characters contiguously into the store.
		  '
		  ' - Returns a dictionary containing the results of the tests.
		  '
		  ' - Notes:
		  ' Starts with an existing store of characters.
		  ///
		  
		  Const storeSize = 20000
		  Const iterations = 50000
		  Const char = "a"
		  Var r As Random = System.Random
		  Var iMax As Integer = iterations - 1
		  Var cursorPos As Integer = 400
		  Var initialStoreSizeMax As Integer = storeSize - 1
		  
		  // ====================
		  // Test GapBuffer.
		  // ====================
		  Var gb As New GapBuffer
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    gb.Insert(0, "b")
		  Next i
		  
		  // Now insert our char at the cursor position.
		  Var startGB As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    gb.Insert(cursorPos, char)
		  Next i
		  Var totalGB As Integer = (System.Microseconds - startGB) / 1000
		  
		  // =========================
		  // Test using array storage
		  // =========================
		  Var a As New ArrayStorage
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    a.Insert(0, "b")
		  Next i
		  
		  // Now insert our char at the cursor position.
		  Var starta As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    a.Insert(cursorPos, char)
		  Next i
		  Var totala As Integer = (System.Microseconds - starta) / 1000
		  
		  // =========================
		  // Test using string storage
		  // =========================
		  Var s As New StringStorage
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    s.Insert(0, "b")
		  Next i
		  
		  // Now insert our char at the cursor position.
		  Var starts As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    s.Insert(cursorPos, char)
		  Next i
		  Var totals As Integer = (System.Microseconds - starts) / 1000
		  
		  Return New Dictionary("GapBuffer" : totalGB, "Array" : totala, "String" : totals)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TestInsertAtRandomLocation() As Dictionary
		  ///
		  ' Tests inserting characters randomly into the store.
		  '
		  ' - Returns a dictionary containing the results of the tests.
		  '
		  ' - Notes:
		  ' Starts with an existing store of characters.
		  ///
		  
		  Const storeSize = 20000
		  Const iterations = 50000
		  Const char = "a"
		  Var r As Random = System.Random
		  Var iMax As Integer = iterations - 1
		  Var initialStoreSizeMax As Integer = storeSize - 1
		  
		  // ====================
		  // Test GapBuffer.
		  // ====================
		  Var gb As New GapBuffer
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    gb.Insert(0, "b")
		  Next i
		  
		  // Now insert our char into random locations.
		  Var startGB As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    Var index As Integer = r.InRange(0, initialStoreSizeMax)
		    gb.Insert(index, char)
		  Next i
		  Var totalGB As Integer = (System.Microseconds - startGB) / 1000
		  
		  // =========================
		  // Test using array storage
		  // =========================
		  Var a As New ArrayStorage
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    a.Insert(0, "b")
		  Next i
		  
		  // Now insert our char into random locations.
		  Var starta As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    Var index As Integer = r.InRange(0, initialStoreSizeMax)
		    a.Insert(index, char)
		  Next i
		  Var totala As Integer = (System.Microseconds - starta) / 1000
		  
		  // =========================
		  // Test using string storage
		  // =========================
		  Var s As New StringStorage
		  // Populate the store with the letter "b".
		  For i As Integer = 0 To initialStoreSizeMax
		    s.Insert(0, "b")
		  Next i
		  
		  // Now insert our char into random locations.
		  Var starts As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    Var index As Integer = r.InRange(0, initialStoreSizeMax)
		    s.Insert(index, char)
		  Next i
		  Var totals As Integer = (System.Microseconds - starts) / 1000
		  
		  Return New Dictionary("GapBuffer" : totalGB, "Array" : totala, "String" : totals)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TestInsertAtStart() As Dictionary
		  ///
		  ' Tests inserting characters to the beginning of the store.
		  '
		  ' - Returns a dictionary containing the results of the tests.
		  ///
		  
		  Const iterations = 50000
		  Const char = "a"
		  Var iMax As Integer = iterations - 1
		  
		  // ====================
		  // Test GapBuffer.
		  // ====================
		  Var gb As New GapBuffer
		  Var startGB As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    gb.Insert(0, char)
		  Next i
		  Var totalGB As Integer = (System.Microseconds - startGB) / 1000
		  
		  // =========================
		  // Test using array storage
		  // =========================
		  Var a As New ArrayStorage
		  Var starta As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    a.Insert(0, char)
		  Next i
		  Var totala As Integer = (System.Microseconds - starta) / 1000
		  
		  // =========================
		  // Test using string storage
		  // =========================
		  Var s As New StringStorage
		  Var starts As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    s.Insert(0, char)
		  Next i
		  Var totals As Integer = (System.Microseconds - starts) / 1000
		  
		  Return New Dictionary("GapBuffer" : totalGB, "Array" : totala, "String" : totals)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TestReplaceAtRandomPosition() As Dictionary
		  ///
		  ' Tests repeatedly replacing a random stretch of characters.
		  '
		  ' - Returns a dictionary containing the results of the tests.
		  '
		  ' - Notes:
		  ' Starts with an existing store of characters.
		  ///
		  
		  Const storeSize = 50000
		  Const iterations = 10000
		  Const replacement = "ab"
		  Var r As Random = System.Random
		  Var iMax As Integer = iterations - 1
		  Var initialStoreSizeMax As Integer = storeSize - 1
		  
		  // ====================
		  // Test GapBuffer.
		  // ====================
		  Var gb As New GapBuffer
		  // Populate the store with the letter "x".
		  For i As Integer = 0 To initialStoreSizeMax
		    gb.Insert(0, "x")
		  Next i
		  
		  // Now replace a random short segment of text with our replacement string.
		  Var startGB As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    // We won't replace more than 5 chars
		    gb.Replace(r.InRange(0, gb.Length - 5), r.InRange(0, 5), replacement)
		  Next i
		  Var totalGB As Integer = (System.Microseconds - startGB) / 1000
		  
		  // =========================
		  // Test using array storage
		  // =========================
		  Var a As New ArrayStorage
		  // Populate the store with the letter "x".
		  For i As Integer = 0 To initialStoreSizeMax
		    a.Insert(0, "x")
		  Next i
		  
		  // Now replace a random short segment of text with our replacement string.
		  Var starta As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    // We won't replace more than 5 chars
		    a.Replace(r.InRange(0, a.Length - 5), r.InRange(0, 5), replacement)
		  Next i
		  Var totala As Integer = (System.Microseconds - starta) / 1000
		  
		  // =========================
		  // Test using string storage
		  // =========================
		  Var s As New StringStorage
		  // Populate the store with the letter "x".
		  For i As Integer = 0 To initialStoreSizeMax
		    s.Insert(0, "x")
		  Next i
		  
		  // Now replace a random short segment of text with our replacement string.
		  Var starts As Double = System.Microseconds
		  For i As Integer = 0 To iMax
		    // We won't replace more than 5 chars
		    s.Replace(r.InRange(0, s.Length - 5), r.InRange(0, 5), replacement)
		  Next i
		  Var totals As Integer = (System.Microseconds - starts) / 1000
		  
		  Return New Dictionary("GapBuffer" : totalGB, "Array" : totala, "String" : totals)
		  
		End Function
	#tag EndMethod


	#tag Note, Name = About
		Experiments with the fastest way to store a large amount of characters.
		Part of a larger text editor project that will use one of these techniques.
		
		
	#tag EndNote


#tag EndWindowCode

#tag ViewBehavior
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Metal Window"
			"11 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="0"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&hFFFFFF"
		Type="Color"
		EditorType="Color"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="MenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
