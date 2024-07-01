#!/bin/bash
############################################
gcode_path=/home/mks/printer_data/gcodes
temp_path=/tmp
new_gcode_path=/home/mks/printer_data/gcodes
new_gcode_file_name=interupted_${2}
############################################

echo "interupted print ${gcode_path}/${2}"
rm "${new_gcode_path}/${new_gcode_file_name}"
cat "${gcode_path}/${2}" > ${temp_path}/plrtmpA.$$

isInFile=$(cat /tmp/plrtmpA.$$ | grep -c "thumbnail")
if [ $isInFile -eq 0 ]; then
     echo 'M109 S200.0' > "${new_gcode_path}/${new_gcode_file_name}"
     cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -ne '/ Z/,$ p' | grep -m 1 ' Z' | sed -ne 's/.* Z\([^ ]*\) /SET_KINEMATIC_POSITION Z=\1/p' >> "${new_gcode_path}/${new_gcode_file_name}"
else
    sed -i '1s/^/;start copy\n/' /tmp/plrtmpA.$$
    sed -n '/;start copy/, /thumbnail end/ p' < /tmp/plrtmpA.$$ > "${new_gcode_path}/${new_gcode_file_name}"
    echo ';' >> "${new_gcode_path}/${new_gcode_file_name}"
    echo '' >> "${new_gcode_path}/${new_gcode_file_name}"
    echo 'M109 S199.0' >> "${new_gcode_path}/${new_gcode_file_name}"
    cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -ne '/ Z/,$ p' | grep -m 1 ' Z' | sed -ne 's/.* Z\([^ ]*\) /SET_KINEMATIC_POSITION Z=\1/p' >> "${new_gcode_path}/${new_gcode_file_name}"
fi
echo 'G91' >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'G1 Z5' >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'G90' >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'G28 X Y' >> "${new_gcode_path}/${new_gcode_file_name}"

# Extruder Temp
# Bring print_temp in save_variables.cfg
echo 'M104 S'${3} >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'M109 S'${3} >> "${new_gcode_path}/${new_gcode_file_name}"

# cat /tmp/plrtmpA.$$ | sed '/ ;Z'${1}'/q' | sed -ne '/\(M104\|M140\|M109\|M190\|M106\)/p' >> "${new_gcode_path}/${new_gcode_file_name}"
# cat /tmp/plrtmpA.$$ | sed '/ ;Z'${1}'/q' | sed -ne '/\(M140\|M190\|M106\)/p' >> "${new_gcode_path}/${new_gcode_file_name}"

# Find the last M106 before Z_LOG
cat /tmp/plrtmpA.$$ | sed '/ ;Z'${1}'/q' | sed -ne '/\(M106\)/p' | head -1 >> "${new_gcode_path}/${new_gcode_file_name}"

# Bed Temp
# Find material_bed_temperature after ;End of Gcode
# cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_print_temperature | sed -ne 's/.* = /M104 S/p' | head -1 >> "${new_gcode_path}/${new_gcode_file_name}"
#cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_bed_temperature | sed -ne 's/.* = /M140 S/p' | head -1 >> "${new_gcode_path}/${new_gcode_file_name}"
# cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_print_temperature | sed -ne 's/.* = /M109 S/p' | head -1 >> "${new_gcode_path}/${new_gcode_file_name}"
#cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_bed_temperature | sed -ne 's/.* = /M190 S/p' | head -1 >> "${new_gcode_path}/${new_gcode_file_name}"
# Bring print_bed_temp in save_variables.cfg
echo 'M140 S'${4} >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'M190 S'${4} >> "${new_gcode_path}/${new_gcode_file_name}"

# Extruder lenght G92 Extruder
# cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -e '/ Z/q' | tac | grep -m 1 ' E' | sed -ne 's/.* E\([^ ]*\)/G92 E\1/p' >> "${new_gcode_path}/${new_gcode_file_name}"
tac /tmp/plrtmpA.$$ | sed -e '/ Z'${1}'[^0-9]*$/q' | tac | tail -n+2 | sed -e '/ Z[0-9]/ q' | tac | sed -e '/ E[0-9]/ q' | sed -ne 's/.* E\([^ ]*\)/G92 E\1/p' >> "${new_gcode_path}/${new_gcode_file_name}"
# cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${1}'/ d' | sed -ne '/ Z/,$ p' >> "${new_gcode_path}/${new_gcode_file_name}"

echo 'G91' >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'G1 Z-5' >> "${new_gcode_path}/${new_gcode_file_name}"
echo 'G90' >> "${new_gcode_path}/${new_gcode_file_name}"

# Copy from fisrt G1 Z...
tac /tmp/plrtmpA.$$ | sed -e '/ Z'${1}'[^0-9]*$/q' | tac | tail -n+2 | sed -ne '/ Z/,$ p' >> "${new_gcode_path}/${new_gcode_file_name}"
echo "file ready ${new_gcode_path}/${new_gcode_file_name}"
/bin/sleep 1