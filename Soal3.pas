program databaseMahasiswa;
uses crt, sysutils; { SysUtils menyediakan Trim, UpperCase, dan StringOfChar. }

type
matkul = record //Menyimpan datanya untuk bagian mata kuliah yang diinnput beserta isinya
    namaMatkul,nilai : string;
    sks : Integer;
    skor : real;
end;

dataMahasiswa = record
    nama: string[35]; //maksimal 35 karakter string
    jumlahMatkul,totalSKS : Integer;
    nim : string[9]; //wajib input 9 digit angka NIM
    daftarMatkul : array of matkul; // Dynamic array untuk matkul
    totalSkor, ipk : real;
end;

function konversiNilai(nh : string) : real; //Memakai Funcction untuk memanggil si nilai dan dikonversi menjadi anngka untuk skor
begin
    nh := UpperCase(Trim(nh)); //Hapus spasi di tepi dan ngubah huruf langsung dibikin ke kapital

    case nh of
        'A'  : konversiNilai := 4.0;
        'B+' : konversiNilai := 3.5;
        'B'  : konversiNilai := 3.0;
        'C+' : konversiNilai := 2.5;
        'C'  : konversiNilai := 2.0;
        'D'  : konversiNilai := 1.0;
        'E'  : konversiNilai := 0.0; // Nilai sah dengan skor 0
    else
        konversiNilai := -1.0; //Penanda nilai yang dimasukkan tidak valid
    end;
end;

function bacaBilanganPositif(const pesan: string) : Integer; //Meminta input ulang sampai pengguna memasukkan bilangan bulat positif
var 
teks: string;
angka, k, kodeError: Integer;
valid: boolean;
begin
    repeat //Diulang terus sampai nginputin data integer yang sesuai
        write(pesan);
        readln(teks);
        teks := Trim(teks); { Trim membuang spasi di awal dan akhir teks. }
        valid := length(teks) > 0; //Pastikan input tidak kosong
        for k := 1 to length(teks) do
            if not (teks[k] in ['0'..'9']) and not ((k = 1) and (teks[k] in ['+', '-'])) then
                valid := false; // Izinkan hanya angka dan tanda di posisi pertama.
        if valid then
        begin
            Val(teks, angka, kodeError); // Ubah teks menjadi integer
            valid := kodeError = 0;     // kode 0 berarti konversi berhasil
        end;
        if not valid then
            writeln('Input harus berupa bilangan bulat.')
        else if angka < 1 then
        begin
            writeln('Input harus bilangan bulat positif minimal 1.');
            valid := false; //Minta input ulang jika angka 0 atau negatif
        end;
    until valid;
    bacaBilanganPositif := angka; //Kembalikan angka yang sudah lolos divalidasi 
end;

//Menambahkan spasi kiri dan kanan agar teks tampak di tengah kolom
function teksTengah(teks: string; lebar: Integer): string;
var
spasiKiri, spasiKanan: Integer;
begin
    if length(teks) > lebar then
        teks := Copy(teks, 1, lebar); //Potong teks jika melebihi lebar kolom
    spasiKiri := (lebar - length(teks)) div 2; //Hitung spasi di sebelah kiri
    spasiKanan := lebar - length(teks) - spasiKiri; //Sisa spasii diletakkan di kanan
    teksTengah := StringOfChar(' ', spasiKiri) + teks +
                  StringOfChar(' ', spasiKanan); //Gabungkan Spasi dan teks
end;

var
namaInput, nimInput : string;
nimAngka : longint;
kodeError : Integer; 
nilaiAngka : real;
namaValid, namaAdaAngka, namaDuplikat: boolean; //Buat deteksi untuk Nama
nimValid, nimDuplikat: boolean; //  dan NIM tidak boleh sama/duplikat, Sehingga Nama dan NIM harus divalidasi 
n, i, j, k : Integer;
pilihan: char;
selesai: boolean;
mahasiswa : array of dataMahasiswa; // Dynamic array untuk mahasiswa

begin
    clrscr;
    n := bacaBilanganPositif('Masukkan jumlah mahasiswa: ');
    SetLength (mahasiswa, n); //Array dinamis

    for i := 0 to n - 1 do //Melakukan perulangan (untuk data mahasiswa yang diinput)
    begin
        writeln;
        writeln('========== Mahasiswa ke-', i + 1, ' dari ', n, ' ==========');
        repeat
            write ('Masukkan Nama Mahasiswa: '); //Masukkan nama mahasiswa
            readln (namaInput);
            namaInput := Trim(namaInput); 

            namaValid := true;
            if length(namaInput) = 0 then
            begin
                writeln ('Nama tidak boleh kosong.'); //Kalok nginput kosong/blank disuruh nginput ulang
                namaValid := false;
            end;
            if length(namaInput) > 35 then //Kelebihan 35 karakter disuruh nginput ulang (batas maksimal karakter)
            begin
                writeln ('Nama maksimal 35 karakter.');
                namaValid := false;
            end;

            namaAdaAngka := false;
            for k := 1 to length(namaInput) do
                if namaInput[k] in ['0'..'9'] then //Ada angka apapun di Nama ?, input ulang !
                    namaAdaAngka := true; //Saya memang logically nama Mahasiswa itu tidak boleh ada angka
            if namaAdaAngka then
            begin
                writeln ('Nama tidak boleh mengandung angka.');
                namaValid := false;
            end;

            namaDuplikat := false;
            for k := 0 to i - 1 do
                if UpperCase(Trim(mahasiswa[k].nama)) = UpperCase(namaInput) then //Mmebandingkan nama sebelumnya tanpa membedakan kapitalisasi
                    namaDuplikat := true;
            if namaDuplikat then
            begin
                writeln ('Nama sudah digunakan; masukkan nama lain.');
                namaValid := false;
            end;
        until namaValid; //Ulangi Inout sampai nama memenuhi semua pemeriksaan
        mahasiswa[i].nama := namaInput;

        repeat
            write('Masukkan NIM (9 digit): ');
            readln(nimInput);
            nimInput := Trim(nimInput);

            nimValid := length(nimInput) = 9; //NIM yang wajib diinput sebanyak 9 digit
            if nimValid then
                for k := 1 to length(nimInput) do
                    if not (nimInput[k] in ['0'..'9']) then
                        nimValid := false;

            if not nimValid then 
                writeln('NIM harus tepat 9 digit angka.')
            else
            begin
                Val(nimInput, nimAngka, kodeError); //Memeriksa apakah adanya indikasi string/teks/karakter pada NIM
                nimValid := kodeError = 0;
                if not nimValid then
                    writeln('NIM bukan bilangan yang valid.')
                else if nimAngka < 1 then
                begin
                    writeln('NIM harus lebih besar dari 0.'); //Input bilangan Negatif dan bilangan 0
                    nimValid := false;
                end;
            end;

            nimDuplikat := false;
            if nimValid then
                for k := 0 to i - 1 do
                    if mahasiswa[k].nim = nimInput then
                        nimDuplikat := true;
            if nimDuplikat then
                writeln ('NIM sudah digunakan; masukkan NIM lain.'); //Same thing juga, berlaku untuk NIM untuk
        until nimValid and not nimDuplikat; // mendeteksi adanya NIM yang sama/duplikat

        mahasiswa[i].nim := nimInput;  
        mahasiswa[i].jumlahMatkul :=
            bacaBilanganPositif('Masukkan jumlah mata kuliah: '); //Masukkan Jumlah Mata Kuliah

        SetLength(mahasiswa[i].daftarMatkul, mahasiswa[i].jumlahMatkul); //Menyiapkan array dinamis ke-2
        mahasiswa[i].totalSKS := 0; //Inisialisasi semuanya dengan total 0
        mahasiswa[i].totalSkor := 0; // Mengawali total skor mahasiswa dari 0.
        for j := 0 to mahasiswa[i].jumlahMatkul - 1 do //looping array dinamis
        begin
            repeat
                write ('Masukkan Nama Mata Kuliah ke-', j + 1, ' : '); readln (namaInput);
                namaInput := Trim(namaInput); //Menghapus spasi di awal dan di akhir nama
                if (length(namaInput) < 8) or (length(namaInput) > 35) then //Setidaknya nama matkul berkisar antara 8 - 35 karakter
                    writeln ('Nama Mata Kuliah harus 8 sampai 35 karakter.');
            until (length(namaInput) >= 8) and (length(namaInput) <= 35); // Ulangi sampai panjang nama sesuai batas.
            
            mahasiswa[i].daftarMatkul[j].namaMatkul := namaInput; // Simpan nama pada mata kuliah ke-j milik mahasiswa ke-i.

            mahasiswa[i].daftarMatkul[j].sks :=
                bacaBilanganPositif('Masukkan jumlah SKS: '); //Masukkan jumlah SKS disertai function yang dipanggil
            // Minta nilai huruf berulang kali sampai nilainya dikenali.
            repeat
                write('Masukkan nilai (A, B+, B, C+, C, D, E): ');
                readln(mahasiswa[i].daftarMatkul[j].nilai);
                mahasiswa[i].daftarMatkul[j].nilai :=
                    UpperCase(Trim(mahasiswa[i].daftarMatkul[j].nilai)); // Rapikan spasi dan ubah huruf menjadi kapital.
                nilaiAngka :=
                    konversiNilai(mahasiswa[i].daftarMatkul[j].nilai); // Ubah nilai huruf menjadi angka.
                if nilaiAngka < 0 then
                    writeln('Nilai tidak valid. Masukkan salah satu nilai yang tersedia.');
            until nilaiAngka >= 0; // Nilai -1 berarti input tidak valid; E tetap sah dengan nilai 0.

            mahasiswa[i].daftarMatkul[j].skor :=
                mahasiswa[i].daftarMatkul[j].sks * nilaiAngka; // Skor mata kuliah = SKS dikali angka nilai.
            mahasiswa[i].totalSKS := mahasiswa[i].totalSKS + mahasiswa[i].daftarMatkul[j].sks; // Tambahkan SKS ke total mahasiswa.
            mahasiswa[i].totalSkor := mahasiswa[i].totalSkor + mahasiswa[i].daftarMatkul[j].skor; // Tambahkan skor ke total mahasiswa.
            end; // Selesai mengisi dan menghitung satu mata kuliah.

        if mahasiswa[i].totalSKS > 0 then // Pastikan total SKS tidak nol sebelum membagi.
        begin
            mahasiswa[i].ipk := mahasiswa[i].totalSkor / mahasiswa[i].totalSKS // IP = total skor dibagi total SKS.
        end
        else
        begin
            mahasiswa[i].ipk := 0; // Hindari pembagian dengan nol.
        end;
    end;

    i := 0;
    selesai := false;
    repeat
        clrscr;
        writeln('Nama : ', mahasiswa[i].nama); //Menuliskan Nama Mahasiswa
        writeln('NIM  : ', mahasiswa[i].nim); //Menuliskan NIM
        writeln('+-----+', StringOfChar('-', 37), '+-----+-------+-------+'); // Cetak garis tabel; kolom mata kuliah disediakan selebar 35 karakter.
        // Tampilkan judul kolom; teksTengah menempatkan "Mata Kuliah" di tengah kolom.
        writeln('| ', 'No':3, ' | ', teksTengah('Mata Kuliah', 35),
                ' | ', 'SKS':3, ' | ', 'Nilai':5, ' | ', 'Skor':5, ' |');
        // Cetak garis pemisah dengan lebar yang sama seperti garis atas.
        writeln('+-----+', StringOfChar('-', 37), '+-----+-------+-------+');

        for j := 0 to mahasiswa[i].jumlahMatkul - 1 do //Menampilkan ulang output yang sudah kita inputkan tadi
            writeln('| ', j + 1:3,
                    ' | ', teksTengah(mahasiswa[i].daftarMatkul[j].namaMatkul, 35),
                    ' | ', mahasiswa[i].daftarMatkul[j].sks:3,
                    ' | ', mahasiswa[i].daftarMatkul[j].nilai:5,
                    ' | ', mahasiswa[i].daftarMatkul[j].skor:5:1,
                    ' |');

        writeln('+-----+', StringOfChar('-', 37), '+-----+-------+-------+');
        writeln('| TOTAL', ' ':50, ' | ',
                mahasiswa[i].totalSkor:5:1, ' |');
        writeln('Jumlah SKS : ', mahasiswa[i].totalSKS);
        writeln('IP         : ', mahasiswa[i].ipk:0:2);
        writeln;
        writeln('[B] Back  [N] Next  [A] Akhiri'); //Ada opsi untuk lihat data sebelum dan selanjutnya, dan untu mengakhiri program
        write('Pilihan: ');
        readln(pilihan);
        pilihan := UpCase(pilihan);  // Samakan input menjadi huruf kapital

        case pilihan of
            'B': // Tampilkan data mahasiswa sebelumnya.
            begin
                if i > 0 then
                    i := i - 1
                else
                begin
                    writeln('Ini data mahasiswa pertama.');
                    write('Tekan Enter untuk kembali...');
                    readln;
                end;
            end;
            'N': // Tampilkan data mahasiswa selanjutnya
            begin
                if i < n - 1 then
                    i := i + 1
                else
                begin
                    writeln('Ini data mahasiswa terakhir.');
                    write('Tekan Enter untuk kembali...');
                    readln;
                end;
            end;
            'A': //Akhiri program
                selesai := true;
        else
        begin
            writeln('Pilihan tidak valid. Gunakan B, N, atau A.'); //Input ulang kalau gak sesuai dengan A,N, dan B
            write('Tekan Enter untuk kembali...');
            readln;
        end;
        end;
    until selesai;
end.
