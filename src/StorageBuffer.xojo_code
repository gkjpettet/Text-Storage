#tag Class
Protected Class StorageBuffer
	#tag Method, Flags = &h0
		Sub Constructor(size as integer)
		  Storage = New MemoryBlock(size * BYTES_PER_CHARACTER)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 436F7069657320612072756E206F6620636861726163746572732066726F6D20746865207061737365642073746F726167652062756666657220746F2074686973206F6E652E
		Sub Copy(from As StorageBuffer, fromIndex As Integer, localIndex As Integer, length As Integer)
		  ///
		  ' Copies a run of characters from the passed storage buffer to this one.
		  '
		  ' - Parameter from: The source storage buffer to copy from.
		  ' - Parameter fromIndex: 0-based index of the first character to copy.
		  ' - Parameter localIndex: The index in this storage buffer to copy to.
		  ' - Parameter length: The number of characters to copy.
		  ///
		  
		  #If Not DebugBuild
		    #Pragma DisableBackgroundTasks
		    #Pragma DisableBoundsChecking
		  #EndIf
		  
		  // Indexes and length all have to be multiplied by BYTES_PER_CHARACTER.
		  fromIndex = fromIndex * BYTES_PER_CHARACTER
		  localIndex = localIndex * BYTES_PER_CHARACTER
		  length = length * BYTES_PER_CHARACTER
		  
		  // Can we bail doing nothing?
		  If from.Size = 0 Or length = 0 Then Return
		  
		  Storage.StringValue(localIndex, Min(length, Storage.Size - localIndex)) = _
		  from.Storage.StringValue(fromIndex, min(length, from.Size * BYTES_PER_CHARACTER - fromIndex))
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Size() As Integer
		  Return Storage.Size / BYTES_PER_CHARACTER
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Size(Assigns length As Integer)
		  Storage.Size = length * BYTES_PER_CHARACTER
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 496E7365727473207468652070617373656420737472696E6720696E746F20746869732062756666657220626567696E6E696E672061742060696E646578602E20
		Sub StringValue(index As Integer, length As Integer, Assigns s As String)
		  ///
		  ' Inserts the passed string into this buffer beginning at `index`. 
		  '
		  ' - Parameter index: 0-based index to insert the passed string at.
		  ' - Parameter length: The length of the string to insert. It may be longer than 
		  '                     the passed string.
		  ' - Parameter s: The string to insert.
		  ///
		  
		  
		  If length = 0 Then Return
		  
		  #If BYTES_PER_CHARACTER <> 4
		    // This should never happen.
		    Raise RuntimeException("Invalid BYTES_PER_CHARACTER value")
		  #EndIf
		  
		  // We need to store the data in UTF-32 format.
		  Var newVal As String = s
		  If newVal.Encoding <> Encodings.UTF32 Then
		    newVal = s.ConvertEncoding(Encodings.UTF32)
		  End If
		  
		  index = index * BYTES_PER_CHARACTER
		  length = length * BYTES_PER_CHARACTER
		  
		  If newVal.Bytes <> length Then
		    Var mb As MemoryBlock = newVal
		    If mb.UInt32Value(0) = &h0000FEFF or mb.UInt32Value(0) = &hFFFE0000 Then
		      // Remove the byte order mark (BOM).
		      newVal = mb.StringValue(4, mb.Size - 4)
		    End If
		    
		    If newVal.Bytes <> length Then
		      // This would happen with UTF-16 chars that occupy two 16 bit words.
		      // For example, "🔍" has Length=2 in UTF-16, but has Length=1 in UTF-32 and in UTF-8.
		      // Since we cannot handle this, this must never happen, i.e. the caller may never
		      // handle UTF-16 encoded Strings. If it does, it's an internal bug.
		      Raise New InvalidArgumentException("Internal bug in StorageBuffer")
		    End If
		  End If
		  
		  Storage.StringValue(index, length) = newVal
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732C206173206120537472696E672C20606C656E677468602063686172616374657273207374617274696E672061742060696E646578602E
		Function ToString(index As Integer, length As Integer) As String
		  ///
		  ' Returns, as a String, `length` characters starting at `index`.
		  '
		  ' - Parameter index: 0-based position in the buffer of the first character to return.
		  ' - Parameter length: The number of characters to return.
		  '
		  ' - Notes:
		  ' If `(index + length) > Size` then all characters from index onwards are returned.
		  ///
		  
		  If length = 0 Then Return ""
		  If index >= Size Then Return ""
		  
		  index = index * BYTES_PER_CHARACTER
		  length = length * BYTES_PER_CHARACTER
		  
		  Var res As String = Storage.StringValue(index, Min(length, Storage.Size - index))
		  res = res.DefineEncoding(Encodings.UTF32)
		  
		  Return res.ConvertEncoding(Encodings.UTF8)
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private Storage As MemoryBlock
	#tag EndProperty


	#tag Constant, Name = BYTES_PER_CHARACTER, Type = Double, Dynamic = False, Default = \"4", Scope = Private, Description = 546865206E756D626572206F66206279746573207573656420746F2073746F726520656163682063686172616374657220696E7465726E616C6C792E
	#tag EndConstant


	#tag ViewBehavior
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
