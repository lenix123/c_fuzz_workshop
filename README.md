docker build -t bmstu_fuzz_img .
docker run -it --name="bmstu_fuzz" bmstu_fuzz_img
./configure && make
