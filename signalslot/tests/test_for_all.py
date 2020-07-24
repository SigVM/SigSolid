import os
test_folder = ["basic/bind_detach",
"basic/broadcast",
"basic/heartbeat",
"basic/multi_bind",
"basic/old_tests/signaltest",
"basic/old_tests/tb5",
"basic/old_tests/blank_data",
"basic/old_tests/slot_creation",
"./feed",
"./timelock"]
f_name_arr = []
os.system("echo To use test_for_all, make sure insert your test directory in test_for_all.py")
for i in test_folder:
    f_name_arr = i.split("/")
    f_name = f_name_arr[-1]
    os.system("echo RUN: ../parse.pl " + i + "/" + f_name +".sol " + i + "/" + f_name + "_parsed.sol")
    os.system("../parse.pl " + i + "/" + f_name +".sol " + i + "/" + f_name + "_parsed.sol")
    os.system("echo RUN: ../../build/solc/solc --overwrite -o " + i + "/out --asm --bin --abi " + i + "/" + f_name + "_parsed.sol")
    os.system("../../build/solc/solc --overwrite -o " + i + "/out --asm --bin --abi " + i + "/" + f_name + "_parsed.sol")

