#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <random>
#include <map>
#include "commands_list.h"



// Seed for random number generation
unsigned int SEED;

// Function to generate a random value within a range
int randomInRange(int min, int max) {
    static std::mt19937 gen(SEED); // Initialize random number generator with constant seed
    std::uniform_int_distribution<int> distribution(min, max);
    return distribution(gen);
}


// Function to generate a random register (R0 - R31)
std::string randomRegister(int first = 0, int last = 31) {
    int registerNum = randomInRange(first, last);
    return "R" + std::to_string(registerNum);
}

// Function to generate a random value for an immediate operand (0 - 255)
std::string randomImmediate(int first = 0, int last = 255) {
    return std::to_string(randomInRange(first, last));
}

// Function to generate a random value for an IO location (0 - 63)
std::string randomIOLocation(int first = 0, int last = 63) {
    return randomImmediate(first, last);
}

// Function to generate a random value for an upper register (R16 - R31)
std::string randomUpperRegister() {
    return randomRegister(16, 31);
}

// Function to generate a random displacement value (0 - 63)
std::string randomDisplacement() {
    return randomImmediate(0, 63);
}


std::string randomOperand1(std::string );
std::string randomOperand2(std::string );

int error__print() {
    std::cerr << "Usage: randomASM [LINE [SEED [CHECKPOINT]] ]" <<std::endl;
    std::cerr << "All arguments must be positive integers." <<std::endl; 
    return -1;
}
int main(int argc, char *argv[]) {
    // Parse the command line arguments
    SEED = 0x1CE7U;
    //Number of lines randomized
    int LINE = 100;
    
    // Number of commands executed before a checkpoint is inserted.
    int CHECKPOINT = 100;
    
    if (argc > 1) { 
        LINE = atoi(argv[1]);
        if (LINE == 0) return error__print();
        if (argc>2) {
            SEED = atoi(argv[2]);
            if (SEED == 0) return error__print(); }
        if (argc>3) {
            CHECKPOINT = atoi(argv[3]);
            if (CHECKPOINT == 0) return error__print(); }
    }

    // // Make all letters upper case and take at least 4 spaces for beauty
    // for (Command &C:commands){
    //     for (char &c: C.name) c=toupper(c); // make it capital 
    //     C.name = Cname.append(6-Cname.length(),' ');
    // }

    // for (Command C:commands){
    //     std::cout << R"({")" << C.name << R"(", ")" << C.operand1 << R"(", ")" << C.operand2 << R"("},)"<<std::endl;
    // }

    // Create a map to store the occurrences of each command
    std::map<std::string, int> commandOccurrences;
 
    // Write the commands and their occurrences to a file   
    std::ofstream commandFile("Commands_"+std::to_string(SEED)+".h");
    // Write the commands and their occurrences to a file   
    std::ofstream occurrenceFile("Occurrences_"+std::to_string(SEED)+".txt");
    // Generate LINE lines of commands with randomized operands
    for (int i = 0; i < LINE;i++) {
        // Generate a random command index
        int commandIndex = randomInRange(0, commands.size() - 1);
        const Command& command = commands[commandIndex];

        // Increment the occurrence count for this command
        commandOccurrences[command.name]++;

        // Generate randomized operands based on the command
        std::string operand1, operand2;
        operand1 = randomOperand1(command.operand1);
        operand2 = randomOperand2(command.operand2);
        
       
        if (commandFile.is_open()) {
            std::string comm = "\"" + command.name + "\t" + operand1;
            if (operand2!="") {
                comm+= (", " + operand2);
            } 
            comm +=  "\" ";
            comm.append(25-comm.length(),' ');
            comm +="\"\\n\\t\"";
            
            commandFile << comm << std::endl;
            if (((i+1)%CHECKPOINT ==0) || (i==LINE-1)) {
                comm = "\"NOP\"                    \"\\n\\t\"";
                commandFile << comm << std::endl;
                comm = "\"CALL\tCRC_REGISTERS%=\" \"\\n\\t\"";
                commandFile << comm << std::endl;                
                comm = "\"CALL\tDUMP_REGS%=\"     \"\\n\\t\"";
                commandFile << comm << std::endl;;

            }
        } else {
            std::cerr << "Unable to open file for writing" << std::endl;
        }
         //Add memdump commands and CRC after CHECKPOINT commands were executed.
        
    }
    std::cout << "Generated " << LINE <<" lines of assembly code."<<std::endl;
    std::cout << "Commands and their operands are written to Commands_"<<SEED<<".h" << std::endl;
    commandFile.close();


    if (occurrenceFile.is_open()) {
        for (const auto& [command, occurrence] : commandOccurrences) {
            occurrenceFile << command << "\t" << occurrence << std::endl;
        }
        occurrenceFile.close();
        std::cout << "Commands and their occurrences are written to Occurrences_"<<SEED<<".txt" << std::endl;
    } else {
        std::cerr << "Unable to open file for writing" << std::endl;
    }

    return 0;
}

std::string randomOperand1(std::string opernd) {
    std::string op_ret;
    if (opernd == "r") {
            op_ret = randomRegister();
    } else if (opernd == "w") {
        std::string displacements[] = {"R24", "R26", "R28", "R30"};
        op_ret = displacements[randomInRange(0,3)];
    } else if (opernd == "d") {
        op_ret = randomUpperRegister();
    } else if (opernd == "a") {
        op_ret = randomRegister(16, 23);  
    } else if (opernd == "B") {
        op_ret = randomImmediate(0, 7);
    } else if (opernd == "re") {
        op_ret = "R"  + std::to_string(randomInRange(0,15)*2);
    } else if (opernd == "e") {
        // Generate random value from X, Y, Z, X+, Y+, Z+, -X, -Y, -Z
        std::string displacements[] = {"X", "Y", "Z", "X+", "Y+", "Z+", "-X", "-Y", "-Z"};
        op_ret = displacements[randomInRange(0, 8)];
    } else if (opernd == "b") {
        // Generate random displacement value
        std::string displacements[] = {"Y+", "Z+"};
        op_ret = displacements[randomInRange(0, 1)] + randomDisplacement();
    } else if (opernd == "io") {
        op_ret = randomIOLocation();
    } else if (opernd == "iol") {
        op_ret = randomIOLocation(0, 31);    
    } else if (opernd == "sram") {
        op_ret = randomImmediate(0+256, 2047+256);
    } else if (opernd == "rx") {
            op_ret = randomRegister(0,25);
    } else if (opernd == "rz") {
            op_ret = randomRegister(0,29);
    } else op_ret = opernd;
    return op_ret;
}

std::string randomOperand2(std::string opernd) {
    std::string op_ret;
    if (!opernd.empty()) {
        if (opernd == "r") {
            op_ret = randomRegister();
        } else if (opernd == "d") {
            op_ret = randomUpperRegister();
        } else if (opernd == "I") {
            op_ret = randomImmediate(0, 63);
        } else if (opernd == "M") {
            op_ret = randomImmediate(0, 255);
        } else if (opernd == "a") {
            op_ret = randomRegister(16, 23);
        } else if (opernd == "B") {
            op_ret = randomImmediate(0, 7);
        } else if (opernd == "re") {
            op_ret = "R"  + std::to_string(randomInRange(0,15)*2);
        } else if (opernd == "e") {
            // Generate random value from X, Y, Z, X+, Y+, Z+, -X, -Y, -Z
            std::string displacements[] = {"X", "Y", "Z", "X+", "Y+", "Z+", "-X", "-Y", "-Z"};
            op_ret = displacements[randomInRange(0, 8)];
        } else if (opernd == "b") {
            // Generate random displacement value
            std::string displacements[] = {"Y+", "Z+"};
            op_ret = displacements[randomInRange(0, 1)] + randomDisplacement();
        } else if (opernd == "io") {
            op_ret = randomIOLocation();
        } else if (opernd == "sram") {
            op_ret = randomImmediate(256, 2047+256);
        } else if (opernd == "z") {
            std::string displacements[] = {"Z", "Z+"};
            op_ret = displacements[randomInRange(0, 1)];
        }  else if (opernd == "rx") {
            op_ret = randomRegister(0,25);
        }
    }
    return op_ret;
}
