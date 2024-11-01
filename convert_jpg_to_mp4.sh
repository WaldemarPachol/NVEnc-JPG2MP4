#!/bin/bash

#
# Ustawienia
#
input_dir="."  # Katalog wejściowy z plikami JPG
output_file="output.mp4"  # Nazwa pliku wyjściowego MP4
block_size=50  # Liczba obrazów w jednym bloku obróbki
max_instances=4  # Maksymalna liczba równoczesnych instancji ffmpeg
video_bitrate="50M"  # Bitrate wideo

#
# Sprawdź, czy katalog wejściowy istnieje
#
if [ ! -d "$input_dir" ]; then
  echo "Katalog $input_dir nie istnieje!"
  exit 1
fi

#
# Znajdź wszystkie pliki JPG w katalogu wejściowym i upewnij się, że globbing zwraca pustą tablicę, gdy brak pasujących plików
#
shopt -s nullglob  # 
images=("$input_dir"/*.jpg "$input_dir"/*.JPG)
total_images=${#images[@]}

#
# Sprawdź, czy są obrazy do konwersji
#
if [ "$total_images" -eq 0 ]; then
  echo "Brak plików JPG w katalogu $input_dir!"
  exit 1
fi

#
# Funkcja do konwertowania obrazu na MP4
#
convert_block() {
  local start_index=$1
  local end_index=$2
  local block_file="block_${start_index}_${end_index}.mp4"
  local file_list="file_list_${start_index}_${end_index}.txt"

  #
  # Przygotowanie pliku z listą obrazów do konwersji
  #
  > "$file_list"  # Zainicjalizuj plik

  for ((i=start_index; i<=end_index; i++)); do
    echo "file '${images[i]}'" >> "$file_list"
  done

  #
  # Użycie ffmpeg do konwersji z ustawionym bitrate
  #
  echo "Przetwarzam obrazy od ${images[start_index]} do ${images[end_index]}"
  ffmpeg -y -f concat -safe 0 -i "$file_list" -vf "scale=4096:-1" -b:v "$video_bitrate" -c:v h264_nvenc -pix_fmt yuv420p "$block_file"
  
  if [ $? -ne 0 ]; then
    echo "Błąd konwersji bloku $start_index-$end_index!"
    exit 1
  fi

  #
  # Usuwanie pliku listy po konwersji
  #
  rm -f "$file_list"
}

#
# Konwersja obrazów w blokach
#
for ((i=0; i<total_images; i+=block_size)); do
  end_index=$((i + block_size - 1))
  if [ "$end_index" -ge "$total_images" ]; then
    end_index=$((total_images - 1))
  fi

  #
  # Logowanie
  #
  echo "Uruchamiam konwersję dla obrazów od $i do $end_index"

  #
  # Wywołanie konwersji w tle
  #
  convert_block $i $end_index &

  #
  # Ograniczenie liczby równoczesnych instancji
  #
  while [ "$(jobs -r -p | wc -l)" -ge "$max_instances" ]; do
    sleep 1
  done
done

#
# Czekaj na zakończenie wszystkich procesów
#
wait

#
# Łączenie plików MP4 w jeden
#
echo "Łączenie plików MP4..."
if ls block_*.mp4 1> /dev/null 2>&1; then
  # Sortowanie bloków według numeru
  for block in $(ls block_*.mp4 | sort -V); do
    echo "file '$block'" >> file_list.txt
  done

  ffmpeg -f concat -safe 0 -i file_list.txt -c copy "$output_file"
  rm file_list.txt
else
  echo "Brak plików do łączenia!"
fi

#
# Usuwanie plików blokowych
#
rm -f block_*.mp4

echo "Konwersja zakończona! Plik wyjściowy: $output_file"