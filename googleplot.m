clc

fn_kml = 'test.kml';
point_color = 'M';                                                          %�}�[�J�̐F�w��'Y','M','C','R','G','B','W','K'
track_color = 'M';                                                          %��芸�����w�肷��i������Ȃ���OK�j

prompt = ' plot : ';
Result.spp.pos = input(prompt);

[len nnn] = size(Result.spp.pos);
Result.spp.time = [zeros(len,6)];

data = [Result.spp.time Result.spp.pos];                      %Y M D H M S lat lon alt
output_kml123(fn_kml,data,track_color,point_color);

disp �I��