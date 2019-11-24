clc

fn_kml = 'test.kml';
point_color = 'M';                                                          %マーカの色指定'Y','M','C','R','G','B','W','K'
track_color = 'M';                                                          %取り敢えず指定する（いじらなくてOK）

prompt = ' plot : ';
Result.spp.pos = input(prompt);

[len nnn] = size(Result.spp.pos);
Result.spp.time = [zeros(len,6)];

data = [Result.spp.time Result.spp.pos];                      %Y M D H M S lat lon alt
output_kml123(fn_kml,data,track_color,point_color);

disp 終了