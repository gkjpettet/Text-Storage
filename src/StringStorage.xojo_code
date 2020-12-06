#tag Class
Protected Class StringStorage
	#tag Method, Flags = &h1, Description = 456E73757265732074686174207468652070617373656420696E6465782069732077697468696E20626F756E64732E2052616973657320616E204F75744F66426F756E6473457863657074696F6E206F74686572776973652E
		Protected Sub CheckBounds(index As Integer)
		  ///
		  ' Ensures that the passed index is within bounds. Raises an OutOfBoundsException otherwise.
		  '
		  ' - Parameter index: The 0-based index value to check.
		  ///
		  
		  If Data = "" And index = 0 Then Return
		  
		  If index < 0 Or index > Data.Length Then
		    Raise New OutOfBoundsException( _
		    "Tried to access the buffer at invalid index. " + _
		    "Logic length = " + Data.Length.ToString + _
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
		  
		  Return Data.Middle(offset, 1)
		  
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
		  If length <= 0 Or Data = "" Then Return ""
		  
		  // Sanity check.
		  CheckBounds(index)
		  CheckBounds(index + length - 1)
		  
		  Return Data.Middle(index, length)
		  
		  
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
		  
		  // Insert at the beginning?
		  If index = 0 Then
		    Data = s + Data
		    Return
		  End If
		  
		  // Append to the end?
		  If index = Data.Length Then
		    Data = Data + s
		    Return
		  End If
		  
		  // Maximum effort...
		  // Get the proximal characters.
		  Var proximal As String = Data.Left(index)
		  
		  // Get the distal characters.
		  Var distal As String = Data.Middle(index)
		  
		  // Do the insertion.
		  Data = proximal + s + distal
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5265706C616365732074686520636861726163746572732066726F6D20696E64657820746F20696E6465782B6C656E677468202077697468207468652070617373656420737472696E672E
		Sub Replace(index As Integer, length As Integer, s As String)
		  ///
		  ' Replaces the characters from `index` to `index+length` with the passed string.
		  '
		  ' - Parameter index: 0-based index to begin the replacement at.
		  ' - Parameter length: The number of characters in the buffer beginning at `index` that
		  '                     are to be replaced with the passed string.
		  ' - Parameter s: The string to replace the existing characters with.
		  '
		  ' - Notes:
		  ' This method can be used to non-destructively insert the passed string by setting 
		  ' `index` to 0.
		  ///
		  
		  // Can we do a simple insert and not a replacement?
		  If length = 0 Then
		    Insert(index, s)
		    Return
		  End If
		  
		  // Sanity check.
		  CheckBounds(index)
		  CheckBounds(index + length - 1)
		  
		  // Ensure UTF-8.
		  s = s.ConvertEncoding(Encodings.UTF8)
		  
		  // Get the proximal characters to preserve.
		  Var proximal As String = Data.Left(index)
		  
		  // Get the distal characters.
		  Var distal As String = Data.Middle(index + length)
		  
		  // Do the insertion.
		  Data = proximal + s + distal
		  
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
		  
		  Data = s
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636F6E74656E7473206F66207468697320417272617953746F7261676520617320612073696E676C6520737472696E672E
		Function ToString() As String
		  ///
		  ' Returns the contents of this buffer as a single string.
		  ///
		  
		  Return Data
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Data As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 546865206C656E677468206F662074686520737472696E672073746F72656420696E2074686973206275666665722E
		#tag Getter
			Get
			  Return Data.Length
			  
			End Get
		#tag EndGetter
		Length As Integer
	#tag EndComputedProperty


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
		#tag ViewProperty
			Name="Data"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
