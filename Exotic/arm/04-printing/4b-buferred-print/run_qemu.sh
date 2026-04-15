aarch64-linux-gnu-as code_arm.s -o temp -I ../../lib/

bytes=$(xxd -p -l8 -g4 -s 160 -e temp)
bytes_trimmed="${bytes:19:8}${bytes:10:8}"
bytes_to_end=$((16#${bytes_trimmed}+120))

xxd -p -s 64 -l "$bytes_to_end" temp | xxd -r -p > binary

rm temp*
chmod +x binary
qemu-aarch64-static ./binary
echo "Exit code: $?"