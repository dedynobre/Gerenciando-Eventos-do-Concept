
Public Function gera_relatorio_se22()
Dim caminho As String
Dim arquivo As String
Dim texto As String
Dim ext As String
Dim nome_arquivo As String
Dim a_ano As String
Dim a_mes As String
Dim a_dia As String
Dim localiza1 As String
Dim localiza2 As String
Dim localiza3 As String
Dim localiza4 As String
Dim modo As String
Dim projeto As String
Dim data As String
Dim horario As String
Dim checa1 As Integer
Dim checa2 As Integer
Dim checa3 As Integer
Dim checa4 As Integer
Dim linha As Long
modo = Cells(2, 3).Value
caminho = "\\local da rede que contem os arquivos .log"
ext = ".log"
localiza1 = "LL984"
localiza2 = "Deleted node"
localiza3 = "Written"
localiza4 = "Modified"
'Close #1
Select Case modo
    Case "Diario":
        a_ano = Year(Date)
        a_mes = Month(Date)
        a_dia = Day(Date)
        nome_arquivo = Format(a_ano & "/" & a_mes & "/" & a_dia, "yyyymmdd") & ext
        arquivo = caminho & nome_arquivo
        str_caminho = arquivo
        If Dir(str_caminho) = vbNullString Then
            str_check = False
        Else
            str_check = True
        End If
        If str_check Then
            Open arquivo For Input As #1
            Do Until EOF(1)
            Line Input #1, texto
            j = InStr(1, texto, ",") + 1           ' Identifica a coluna que contém a primeira virgula da linha
            k = InStr(32, texto, ",") - 1
            l = k - j
            On Error Resume Next
            projeto = Mid(texto, (j + 1), l)          'identica o nome do projeto
            m = InStr(32, texto, ",") + 1
            o = InStr(41, texto, ",") - 1
            p = o - m
            usuario = Mid(texto, (m + 1), p)
            data = Mid(texto, 1, 10)
            horario = Mid(texto, 12, 8)
            desc = Mid(texto, (o + 3), 200)
            checa1 = InStr(1, desc, localiza1, vbTextCompare)
            checa2 = InStr(1, desc, localiza2, vbTextCompare)
            checa3 = InStr(1, desc, localiza3, vbTextCompare)
            checa4 = InStr(1, desc, localiza4, vbTextCompare)
            If (checa1 > 0) Or (checa2 > 0) Or (checa3 > 0) Or (checa4 > 0) Then
                   Sheets("Relatorio").Select
                   linha = Range("B" & Rows.Count).End(xlUp).Row
                        Cells(linha + 1, 2).Value = data
                        With Cells(linha + 1, 2).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 3).Value = horario
                        With Cells(linha + 1, 3).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 4).Value = projeto
                        With Cells(linha + 1, 4).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 5).Value = usuario
                        With Cells(linha + 1, 5).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 6).Value = desc
                        With Cells(linha + 1, 6).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 7).Value = "Nome da Maquina"
                        With Cells(linha + 1, 7).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
            End If
            Loop
        End If
    Case "Semanal":
        a_ano = Year(Date)
        a_mes = Month(Date)
        a_dia = Day(Date)
        data_inicial = Date
        data_final = DateAdd("d", -7, data_inicial)
        a1_mes = Month(data_final)
        a2_dia = Day(data_final)
        For x = a2_dia To a_dia
            nome_arquivo = Format(a_ano & "/" & a_mes & "/" & x, "yyyymmdd") & ext
            arquivo = caminho & nome_arquivo
            str_caminho = arquivo
            If Dir(str_caminho) = vbNullString Then
                str_check = False
            Else
                str_check = True
            End If
            If str_check Then
                Open arquivo For Input As #1
                Do Until EOF(1)
                    Line Input #1, texto
                    j = InStr(1, texto, ",") + 1           ' Identifica a coluna que contém a primeira virgula da linha
                    k = InStr(32, texto, ",") - 1
                    l = k - j
                    On Error Resume Next
                    projeto = Mid(texto, (j + 1), l)          'identica o nome do projeto
                    m = InStr(32, texto, ",") + 1
                    o = InStr(41, texto, ",") - 1
                    p = o - m
                    usuario = Mid(texto, (m + 1), p)
                    data = Mid(texto, 1, 10)
                    horario = Mid(texto, 12, 8)
                    desc = Mid(texto, (o + 3), 200)
                    checa1 = InStr(1, desc, localiza1, vbTextCompare)
                    checa2 = InStr(1, desc, localiza2, vbTextCompare)
                    checa3 = InStr(1, desc, localiza3, vbTextCompare)
                    checa4 = InStr(1, desc, localiza4, vbTextCompare)
                    If (checa1 > 0) Or (checa2 > 0) Or (checa3 > 0) Or (checa4 > 0) Then
                        Sheets("Relatorio").Select
                        linha = Range("B" & Rows.Count).End(xlUp).Row
                        Cells(linha + 1, 2).Value = data
                        With Cells(linha + 1, 2).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 3).Value = horario
                        With Cells(linha + 1, 3).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 4).Value = projeto
                        With Cells(linha + 1, 4).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 5).Value = usuario
                        With Cells(linha + 1, 5).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 6).Value = desc
                        With Cells(linha + 1, 6).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                        Cells(linha + 1, 7).Value = "Nome da Maquina)"
                        With Cells(linha + 1, 7).Borders
                            .LineStyle = xlContinuous
                            .Weight = xlThin
                        End With
                    End If
                Loop
            End If
            Close #1
        Next
    Case "Mensal":
    Case "Anual":
    Close #1
End Select
End Function
