# Лабораторная работа №3

## Задание 4
**В текстовых файлах (.txt) найти заданную в параметре сценария строку, из найденных файлов составить список, сохранить его в файл. (В данном случае строку "ERROR")**

---

## Выполнение работы

### 1. Создание директории и файлов

Создаем папку:

```powershell
mkdir C:\LABoR_3
```

Создаем файлы:

```powershell

@"
ERROR: Database connection failed
[INFO] System started
ERROR: Timeout occurred
"@ | Out-File -FilePath "C:\LABoR_3\file1.txt" -Encoding UTF8


@"
All systems normal
[INFO] Backup completed
[ERROR]
"@ | Out-File -FilePath "C:\LABoR_3\file2.txt" -Encoding UTF8


@"
[ERROR] Invalid password
[WARNING] Disk space low
[ERROR] Login failed 3 times
"@ | Out-File -FilePath "C:\LABoR_3\file3.txt" -Encoding UTF8


@"
=== LOG ===
Everything OK
No problems found
=== END ===
"@ | Out-File -FilePath "C:\LABoR_3\file4.txt" -Encoding UTF8
```

Команда с нужными параметрами для нахождения и создания файла со списком найденных файлов:

```powershell
Get-ChildItem -Path C:\LABoR_3 -Recurse -Filter "*.txt" | Select-String "ERROR" | Select-Object -Unique Path | Out-File -FilePath "C:\LABoR_3\found_files_list.txt"
```
Результат: файл - find_files_list.txt

```txt
C:\LABoR_3\file1.txt
C:\LABoR_3\file2.txt
C:\LABoR_3\file3.txt
```
Тут конец. Более подробно со скриншотами в ДОК - файле.

