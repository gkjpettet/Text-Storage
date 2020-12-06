#tag Class
Class GapBuffer
	#tag Method, Flags = &h1, Description = 456E73757265732074686174207468652070617373656420696E6465782069732077697468696E20626F756E64732E2052616973657320616E204F75744F66426F756E6473457863657074696F6E206F74686572776973652E
		Protected Sub CheckBounds(index As Integer)
		  ///
		  ' Ensures that the passed index is within bounds. Raises an OutOfBoundsException otherwise.
		  '
		  ' - Parameter index: The 0-based index value to check.
		  ///
		  
		  If index < 0 Or index > Length Then
		    Raise New OutOfBoundsException( _
		    "Tried to access the buffer at invalid index. " + _
		    "Logic length = " + Length.ToString + _
		    ", index = "+ index.ToString)
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor()
		  Buffer = New StorageBuffer(0)
		  GapStart = 0
		  GapEnd = 0
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub EnsureBufferSize(minRequiredLength As Integer)
		  // Makes sure there's at least `minRequiredLength` spaces available in the buffer.
		  #If Not DebugBuild
		    #Pragma DisableBackgroundTasks
		    #Pragma DisableBoundsChecking
		  #EndIf
		  
		  Var newbuffer As StorageBuffer
		  Var delta As Integer
		  
		  If GapLength < minRequiredLength Or GapLength < MIN_GAP_SIZE Then
		    // The gap's too small. Resize buffer.
		    delta = Max(minRequiredLength, MAX_GAP_SIZE) - GapLength
		    newbuffer = New StorageBuffer(buffer.Size + delta)
		    
		  ElseIf GapLength > MAX_GAP_SIZE Then
		    // The gap is too big.
		    delta = Max(minRequiredLength, MIN_GAP_SIZE) - GapLength
		    newbuffer = New StorageBuffer(buffer.Size + delta)
		    
		  Else // No need to resize.
		    Return
		  End If
		  
		  // Copy the contents to the new buffer.
		  newbuffer.Copy(buffer, 0, 0, GapStart)
		  newbuffer.Copy(buffer, GapEnd, newbuffer.Size - (buffer.Size - GapEnd), buffer.Size - GapEnd)
		  
		  // The new buffer is now our buffer.
		  Buffer = newbuffer
		  
		  // Update the gap.
		  GapEnd = GapEnd + delta
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636861726163746572206174207468652073706563696669656420302D6261736564206F66667365742E
		Function GetCharacterAt(offset As Integer) As String
		  ///
		  ' Returns the character at the specified 0-based offset.
		  '
		  ' - Parameter offset: The 0-based offset of the character to retrieve.
		  ///
		  
		  If offset < gapStart then
		    // The offset is before the gap.
		    Return buffer.ToString(offset, 1)
		  End If
		  
		  // The offset is after the gap so offset it by the gap length.
		  Return buffer.ToString(offset + GapLength, 1)
		  
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
		  If length <= 0 Or Self.Length = 0 Then Return ""
		  
		  // Sanity check.
		  CheckBounds(index)
		  
		  Var delta As Integer = index + length
		  
		  // Are all the characters before the gap?
		  If delta < GapStart Then Return buffer.ToString(index, length)
		  
		  //Are all the characters after the gap?
		  If index > GapStart Then Return buffer.ToString(index + GapLength, length)
		  
		  // Maximum effort. The characters span the gap.
		  Var result As StorageBuffer = New StorageBuffer(length)
		  result.Copy(Buffer, index, 0, GapStart - index)
		  result.Copy(Buffer, GapEnd, GapStart - index, delta - GapStart)
		  
		  Return result.ToString(0, result.Size)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 496E7365727473207468652070617373656420737472696E6720696E746F2074686520627566666572206174207468652073706563696669656420696E6465782E
		Sub Insert(index As Integer, s As String)
		  ///
		  ' Inserts the passed string into the buffer at the specified index.
		  '
		  ' - Parameter index: 0-based index in the buffer to insert the passed string.
		  ' - Parameter s: The string to insert.
		  ///
		  
		  Replace(index, 0, s)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1, Description = 4D6F766573207468652067617020746F206120646966666572656E7420706C61636520696E20746865206275666665722E
		Protected Sub PlaceGap(index As Integer)
		  ///
		  ' Moves the gap to a different place in the buffer.
		  '
		  ' - Parameter index: The 0-based index that the gap should begin at.
		  ///
		  
		  #If Not DebugBuild
		    #Pragma DisableBackgroundTasks
		    #Pragma DisableBoundsChecking
		  #EndIf
		  
		  // Can we do nothing?
		  If index = GapStart And GapLength > 0 Then Return
		  If Buffer.Size = 0 then Return
		  
		  Var newbuffer As StorageBuffer = Buffer
		  
		  If index < GapStart Then
		    // We're moving the gap leftwards, before the current gap.
		    
		    // The number of items to move.
		    Var count As Integer = GapStart - index
		    
		    // Move the items.
		    newbuffer.StringValue(index + GapLength, count) = buffer.ToString(index, count)
		    
		    // Update the gap.
		    GapStart = GapStart - count
		    GapEnd = GapEnd - count
		    
		  Else
		    // We're moving the gap rightwards, after the current gap start.
		    
		    // How many items need to move?
		    Var count As Integer = index - GapStart
		    
		    If count > 0 Then
		      // Move the items.
		      newbuffer.StringValue(GapStart, count) = buffer.ToString(GapEnd, count)
		      
		      // Update the gap.
		      GapStart = GapStart + count
		      GapEnd = GapEnd + count
		    End If
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52656D6F7665732074686520737065636966696564206E756D626572206F6620636861726163746572732066726F6D20746865206275666665722C20626567696E6E696E672061742060696E646578602E
		Function Remove(index As Integer, length As Integer) As Boolean
		  ///
		  ' Removes the specified number of characters from the buffer, beginning at `index`.
		  '
		  ' - Parameter index: The 0-based index of the first character to be removed.
		  ' - Parameter length: The number of characters to remove.
		  '
		  ' - Returns: True if the remove occurred, False if it did not.
		  ///
		  
		  // Sanity check.
		  If index < 0 Or index > Self.Length Or Self.Length = 0 Then Return False
		  
		  Replace(index, length, "")
		  
		  Return True
		  
		End Function
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
		  ///
		  
		  s = s.ConvertEncoding(Encodings.UTF8)
		  
		  CheckBounds(index)
		  
		  PlaceGap(index)
		  
		  // Make sure we have enough space in our storage buffer to take the string.
		  EnsureBufferSize(s.Length)
		  
		  // Replace characters by moving them into the gap.
		  gapEnd = gapEnd + length
		  
		  // Add the passed string.
		  buffer.StringValue(index, s.Length) = s
		  gapStart = gapStart + s.Length
		  
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
		  buffer.Size = s.Length
		  buffer.StringValue(0, s.Length) = s
		  GapStart = s.Length / 2
		  GapEnd = GapStart
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636F6E74656E7473206F6620746869732047617042756666657220617320612073696E676C6520737472696E672E
		Function ToString() As String
		  ///
		  ' Returns the contents of this GapBuffer as a single string.
		  ///
		  
		  Return GetStringAt(0, Self.Length)
		  
		End Function
	#tag EndMethod


	#tag Note, Name = Info
		https://www.codeproject.com/KB/recipes/GenericGapBuffer.aspx
		https://en.wikipedia.org/wiki/Gap_buffer
	#tag EndNote


	#tag Property, Flags = &h1
		Protected Buffer As StorageBuffer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h1, Description = 54686520696E646578206F662074686520656E64206F6620746865206761702E
		#tag Getter
			Get
			  Return mGapEnd
			  
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value > Buffer.Size Then value = Buffer.Size
			  
			  mGapEnd = value
			  
			End Set
		#tag EndSetter
		Protected GapEnd As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 546865206C656E677468206F6620746865206761702E
		#tag Getter
			Get
			  Return GapEnd - GapStart
			  
			End Get
		#tag EndGetter
		GapLength As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h1, Description = 54686520696E646578206F6620746865207374617274206F6620746865206761702E
		Protected GapStart As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 546865206C656E677468206F662074686520737472696E672073746F72656420696E207468697320676170206275666665722E
		#tag Getter
			Get
			  Return buffer.Size - GapLength
			  
			End Get
		#tag EndGetter
		Length As Integer
	#tag EndComputedProperty

	#tag Property, Flags = &h21, Description = 4261636B696E672073746F726520666F7220476170456E642E
		Private mGapEnd As Integer
	#tag EndProperty


	#tag Constant, Name = MAX_GAP_SIZE, Type = Double, Dynamic = False, Default = \"256", Scope = Private, Description = 546865206D6178696D756D2073697A65206F66207468652067617020696E20746865206275666665722E
	#tag EndConstant

	#tag Constant, Name = MIN_GAP_SIZE, Type = Double, Dynamic = False, Default = \"32", Scope = Private, Description = 546865206D696E696D756D207065726D69737369626C652073697A65206F662074686973206275666665722773206761702E
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="GapLength"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Length"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
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
