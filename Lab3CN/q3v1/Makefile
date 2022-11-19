CC = g++
STD = -std=c++17

all:
	$(CC) $(STD) q3server1.cpp -o server_A
	$(CC) $(STD) q3server2.cpp -o server_B
	$(CC) $(STD) q3client.cpp -o client

genfile:
	$(CC) $(STD) random_file_generator.cpp -o random_file_generator
	./random_file_generator
	$(RM) random_file_generator

clean:
	$(RM) target.txt
	$(RM) server_A
	$(RM) server_B
	$(RM) client
