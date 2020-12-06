#tag Class
Protected Class ArrayStorage
	#tag Method, Flags = &h1, Description = 456E73757265732074686174207468652070617373656420696E6465782069732077697468696E20626F756E64732E2052616973657320616E204F75744F66426F756E6473457863657074696F6E206F74686572776973652E
		Protected Sub CheckBounds(index As Integer)
		  ///
		  ' Ensures that the passed index is within bounds. Raises an OutOfBoundsException otherwise.
		  '
		  ' - Parameter index: The 0-based index value to check.
		  ///
		  
		  If Storage.LastIndex = -1 And index = 0 Then Return
		  
		  If index < 0 Or (index > Storage.LastIndex + 1) Then
		    Raise New OutOfBoundsException( _
		    "Tried to access the buffer at invalid index. " + _
		    "Logic length = " + Storage.LastIndex.ToString + _
		    ", index = "+ index.ToString)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636861726163746572206174207468652073706563696669656420302D6261736564206F66667365742E
		Function GetCharacterAt(offset As Integer) As String
		  ///
		  ' Returns the character at the specified 0-based offset.
		  '
		  ' - Parameter offset: The 0-based offset of the character to retrieve.
		  ///
		  
		  Return Storage(offset)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320606C656E677468602063686172616374657273207374617274696E672061742060696E646578602E
		Function GetStringAt(index As Integer, length As Integer) As String
		  ///
		  ' Returns `length` characters starting at `index`.
		  '
		  ' - Parameter index: The 0-based index of the first character of the string to retrieve.
		  ' - Parameter length: The number of characters to return.
		  ///
		  
		  #If Not DebugBuild
		    #Pragma DisableBackgroundTasks
		    #Pragma DisableBoundsChecking
		  #EndIf
		  
		  // Can we do nothing?
		  If length <= 0 Or Storage.Count = 0 Then Return ""
		  
		  // Sanity check.
		  CheckBounds(index)
		  CheckBounds(index + length - 1)
		  
		  Var iMax As Integer = index + length - 1
		  Var chars() As String
		  chars.ResizeTo(length - 1)
		  Var charsIndex As Integer = 0
		  For i As Integer = index To iMax
		    chars(charsIndex) = Storage(i)
		    charsIndex = charsIndex + 1
		  Next i
		  
		  Return String.FromArray(chars, "")
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Insert(index As Integer, s As String)
		  ///
		  ' Inserts the passed string into the buffer at the specified index.
		  '
		  ' - Parameter index: 0-based index in the buffer to insert the passed string.
		  ' - Parameter s: The string to insert.
		  ///
		  
		  s = s.ConvertEncoding(Encodings.UTF8)
		  
		  CheckBounds(index)
		  
		  Var chars() As String = s.Split("")
		  Var iStart As Integer = chars.LastIndex
		  For i As Integer = iStart DownTo 0
		    Storage.AddAt(index, chars(i))
		  Next i
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5265706C616365732074686520636861726163746572732066726F6D20696E64657820746F20696E6465782B6C656E677468202077697468207468652070617373656420737472696E672E
		Sub Replace(index As Integer, length As Integer, s As String)
		  ///
		  ' Replaces the characters from index to index+length  with the passed string.
		  '
		  ' - Parameter index: 0-based index to begin the replacement at.
		  ' - Parameter length: The number of characters in the buffer beginning at `index` that
		  '                     are to be replaced with the passed string.
		  ' - Parameter s: The string to replace the existing characters with.
		  '
		  ' - Notes:
		  ' This method can be used to non-destructively insert the passed string by setting 
		  ' `index` to 0.
		  ' `Storage(index + length)` to `Storage.LastIndex` are the elements at the end of the 
		  ' array that must be kept.
		  
		  ' `Storage(0)` to `Storage(index - 1)` are the elements at the beginning of the array 
		  ' that must also be kept.
		  ///
		  
		  CheckBounds(index)
		  
		  Var iMax As Integer = index + length - 1
		  For i As Integer = iMax DownTo index
		    Storage.RemoveAt(i)
		  Next i
		  
		  Insert(index, s)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5265706C616365732074686520636F6E74656E7473206F662074686973206275666665722077697468207468652070617373656420737472696E672E
		Sub SetString(s As String)
		  ///
		  ' Replaces the contents of this buffer with the passed string.
		  '
		  ' - Parameter s: The string that will replace the contents of this buffer.
		  ///
		  
		  If s.Encoding = Nil Then Raise New InvalidArgumentException("The string has no encoding")
		  
		  s = s.ConvertEncoding(Encodings.UTF8)
		  
		  Storage = s.Split("")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636F6E74656E7473206F66207468697320417272617953746F7261676520617320612073696E676C6520737472696E672E
		Function ToString() As String
		  ///
		  ' Returns the contents of this GapBuffer as a single string.
		  ///
		  
		  Return String.FromArray(Storage, "")
		  
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0, Description = 546865206C656E677468206F662074686520737472696E672073746F72656420696E2074686973206275666665722E
		#tag Getter
			Get
			  Return Storage.Count
			  
			End Get
		#tag EndGetter
		Length As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Storage() As String
	#tag EndProperty


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
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
