#include <iostream>
#include <vector>
#include <string>
#include <cstdint>
#include <random>
#include <cassert>
#include <bitset>
#include <iomanip>
#include <algorithm>

// Constants
#define SCALE 50.0
#define PENALTY_SCALE 800.0
#define MAX_BITS 25
#define MAX_ITER 10000
#define FIXED_TEMPERATURE 8.33
#define E_OFF 2
#define E_OFF_MAX 20

#define MASK_E 0b0000000000000000000011111
#define MASK_D 0b0000000000000001111100000
#define MASK_C 0b0000000000111110000000000
#define MASK_B 0b0000011111000000000000000
#define MASK_A 0b1111100000000000000000000

// Global Variables
std::vector<std::vector<double>> weights_i_j = {
    {0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -12, 0, 0, -12, -PENALTY_SCALE, -10, 0, 0, -10, -PENALTY_SCALE, -19, 0, 0, -19, -PENALTY_SCALE, -8, 0, 0, -8},
    {-PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -12, -PENALTY_SCALE, -12, 0, 0, -10, -PENALTY_SCALE, -10, 0, 0, -19, -PENALTY_SCALE, -19, 0, 0, -8, -PENALTY_SCALE, -8, 0, 0},
    {-PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -12, -PENALTY_SCALE, -12, 0, 0, -10, -PENALTY_SCALE, -10, 0, 0, -19, -PENALTY_SCALE, -19, 0, 0, -8, -PENALTY_SCALE, -8, 0},
    {-PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, 0, 0, -12, -PENALTY_SCALE, -12, 0, 0, -10, -PENALTY_SCALE, -10, 0, 0, -19, -PENALTY_SCALE, -19, 0, 0, -8, -PENALTY_SCALE, -8},
    {-PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -12, 0, 0, -12, -PENALTY_SCALE, -10, 0, 0, -10, -PENALTY_SCALE, -19, 0, 0, -19, -PENALTY_SCALE, -8, 0, 0, -8, -PENALTY_SCALE},
    {-PENALTY_SCALE, -12, 0, 0, -12, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -3, 0, 0, -3, -PENALTY_SCALE, -7, 0, 0, -7, -PENALTY_SCALE, -2, 0, 0, -2},
    {-12, -PENALTY_SCALE, -12, 0, 0, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -3, -PENALTY_SCALE, -3, 0, 0, -7, -PENALTY_SCALE, -7, 0, 0, -2, -PENALTY_SCALE, -2, 0, 0},
    {0, -12, -PENALTY_SCALE, -12, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -3, -PENALTY_SCALE, -3, 0, 0, -7, -PENALTY_SCALE, -7, 0, 0, -2, -PENALTY_SCALE, -2, 0},
    {0, 0, -12, -PENALTY_SCALE, -12, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, 0, 0, -3, -PENALTY_SCALE, -3, 0, 0, -7, -PENALTY_SCALE, -7, 0, 0, -2, -PENALTY_SCALE, -2},
    {-12, 0, 0, -12, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -3, 0, 0, -3, -PENALTY_SCALE, -7, 0, 0, -7, -PENALTY_SCALE, -2, 0, 0, -2, -PENALTY_SCALE},
    {-PENALTY_SCALE, -10, 0, 0, -10, -PENALTY_SCALE, -3, 0, 0, -3, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -6, 0, 0, -6, -PENALTY_SCALE, -20, 0, 0, -20},
    {-10, -PENALTY_SCALE, -10, 0, 0, -3, -PENALTY_SCALE, -3, 0, 0, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -6, -PENALTY_SCALE, -6, 0, 0, -20, -PENALTY_SCALE, -20, 0, 0},
    {0, -10, -PENALTY_SCALE, -10, 0, 0, -3, -PENALTY_SCALE, -3, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -6, -PENALTY_SCALE, -6, 0, 0, -20, -PENALTY_SCALE, -20, 0},
    {0, 0, -10, -PENALTY_SCALE, -10, 0, 0, -3, -PENALTY_SCALE, -3, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, 0, 0, -6, -PENALTY_SCALE, -6, 0, 0, -20, -PENALTY_SCALE, -20},
    {-10, 0, 0, -10, -PENALTY_SCALE, -3, 0, 0, -3, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -6, 0, 0, -6, -PENALTY_SCALE, -20, 0, 0, -20, -PENALTY_SCALE},
    {-PENALTY_SCALE, -19, 0, 0, -19, -PENALTY_SCALE, -7, 0, 0, -7, -PENALTY_SCALE, -6, 0, 0, -6, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -4, 0, 0, -4},
    {-19, -PENALTY_SCALE, -19, 0, 0, -7, -PENALTY_SCALE, -7, 0, 0, -6, -PENALTY_SCALE, -6, 0, 0, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -4, -PENALTY_SCALE, -4, 0, 0},
    {0, -19, -PENALTY_SCALE, -19, 0, 0, -7, -PENALTY_SCALE, -7, 0, 0, -6, -PENALTY_SCALE, -6, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -4, -PENALTY_SCALE, -4, 0},
    {0, 0, -19, -PENALTY_SCALE, -19, 0, 0, -7, -PENALTY_SCALE, -7, 0, 0, -6, -PENALTY_SCALE, -6, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, 0, 0, -4, -PENALTY_SCALE, -4},
    {-19, 0, 0, -19, -PENALTY_SCALE, -7, 0, 0, -7, -PENALTY_SCALE, -6, 0, 0, -6, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -4, 0, 0, -4, -PENALTY_SCALE},
    {-PENALTY_SCALE, -8, 0, 0, -8, -PENALTY_SCALE, -2, 0, 0, -2, -PENALTY_SCALE, -20, 0, 0, -20, -PENALTY_SCALE, -4, 0, 0, -4, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE},
    {-8, -PENALTY_SCALE, -8, 0, 0, -2, -PENALTY_SCALE, -2, 0, 0, -20, -PENALTY_SCALE, -20, 0, 0, -4, -PENALTY_SCALE, -4, 0, 0, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE},
    {0, -8, -PENALTY_SCALE, -8, 0, 0, -2, -PENALTY_SCALE, -2, 0, 0, -20, -PENALTY_SCALE, -20, 0, 0, -4, -PENALTY_SCALE, -4, 0, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE, -PENALTY_SCALE},
    {0, 0, -8, -PENALTY_SCALE, -8, 0, 0, -2, -PENALTY_SCALE, -2, 0, 0, -20, -PENALTY_SCALE, -20, 0, 0, -4, -PENALTY_SCALE, -4, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0, -PENALTY_SCALE},
    {-8, 0, 0, -8, -PENALTY_SCALE, -2, 0, 0, -2, -PENALTY_SCALE, -20, 0, 0, -20, -PENALTY_SCALE, -4, 0, 0, -4, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, -PENALTY_SCALE, 0}
};
std::vector<double> biases_i = {PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE, PENALTY_SCALE};
std::vector<double> localField_h = {};
double E_off = 0;

enum Criterion {
    METROPOLIS,
    GIBBS
};

// State Variable Class
class StateVariable {
private:
    std::bitset<MAX_BITS> bits;

public:
    StateVariable(bool randomize = false) {
        if (randomize) {
            static std::random_device rd;
            static std::mt19937 gen(rd());
            for (int i = 0; i < MAX_BITS; ++i) {
                bits[i] = gen() % 2;
            }
        } else {
            bits.reset();
        }
    }

    uint32_t toUInt32() const {
        return static_cast<uint32_t>(bits.to_ulong());
    }

    void set(size_t index) {
        if (index >= 0 && index < MAX_BITS)
            bits |= (1U << index);
    }

    void program(std::string bitString) {
        for (size_t i = 0; i < bitString.size() && i < MAX_BITS; ++i) {
            if (bitString[i] == '1') {
                set(i);
            } else {
                unset(i);
            }
        }
    }

    void unset(size_t index) {
        if (index < MAX_BITS)
            bits &= ~(1U << index);
    }

    void toggle(size_t index) {
        if (index < MAX_BITS)
            bits ^= (1U << index);
    }

    bool test(size_t index) const
    {
        if (index < MAX_BITS)
            return bits[index];
        return false;
    }

    void print() const
    {
        std::cout << "State: ";
        for (int i = 0; i < MAX_BITS; ++i) {
            if (i % 5 == 0 && i != 0)
                std::cout << " "; // Add space every 5 bits for readability
            std::cout << bits[i];
        }
        //std::cout << std::endl;
    }

    void reset() {
        bits = 0;
    }

    int count() const {
        return bits.count();
    }

};
StateVariable currentState(true);

void setRandomState(uint32_t& value) {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<uint32_t> dis(0, UINT32_MAX);
    value = dis(gen);
}

void scaleWeightsAndBiases(
    std::vector<std::vector<double>>& weights,
    std::vector<double>& biases,
    double scale)
{
    for (size_t i = 0; i < weights.size(); i++)
    {
        for (size_t j = 0; j < weights[i].size(); j++)
        {
            weights[i][j] /= scale;
        }
    }

    for (size_t i = 0; i < biases.size(); i++)
    {
        biases[i] /= scale;
    }
}

void initializeLocalFields(
    const StateVariable& state,
    std::vector<double>& localFields,
    const std::vector<std::vector<double>>& weights,
    const std::vector<double>& biases)
{
    // Clear and resize local fields
    localFields.clear();
    //localFields.resize(MAX_BITS);
    
    //Ensure sizes match
    assert(biases.size() == weights.size());

    // Initialize local fields using formula hi = ΣWij + b_i
    for (size_t i = 0; i < weights.size(); i++)
    {
        int h = biases[i];
        for (size_t j = 0; j < weights[i].size(); j++)
        {
            if (state.test(j))
            {
                h += weights[i][j];
            }
        }
        localFields.push_back(h);
    }

}

double IsingEnergy(
    const std::vector<double>& localFields,
    const StateVariable& state,
    const std::vector<std::vector<double>>& weights)
{
    
    int energy = 0;
    double weightSum = 0;
    double biasSum = 0;

    // Sum of Weights
    for (size_t i = 0; i < weights.size(); i++)
    {
        if (state.test(i))
        {
            for (size_t j = 0; j < weights[i].size();j++)
            {
                if (state.test(j))
                {
                    weightSum += weights[i][j];
                }
            }
        }
    }

    // Sum of Biases
    for (size_t i = 0; i < localFields.size(); i++)
    {
        if (state.test(i))
        {
            biasSum += localFields[i];
        }
    }

    energy = -1.0 * (weightSum + biasSum);

    return energy;
}

double deltaEnergyFull(
    size_t index,
    const std::vector<double>& localFields,
    const StateVariable& state)
{
    double deltaE = 0;

    bool bitState = state.test(index);

    if (bitState)
    {
        // If bit is currently 1
        // Add contributions
        deltaE = localFields[index];
    }
    else
    {
        // If bit is currently 0
        // Subtract contributions
        deltaE = -localFields[index];
    }

    return deltaE;
}

double deltaEnergy(
    size_t index,
    const StateVariable& state,
    const std::vector<double>& localFields)
{
    double deltaE = 0;

    bool bitState = state.test(index);

    if (bitState)
    {
        // If bit is currently 1
        // Add contributions
        deltaE = localFields[index];
    }
    else
    {
        // If bit is currently 0
        // Subtract contributions
        deltaE = -localFields[index];
    }

    return deltaE;
}

double deGloriaFull(
    size_t index,
    const StateVariable& state,
    std::vector<double>& localFields)
{
    double deltaH = 0;
    bool bitState = state.test(index);

    if (bitState)
    {
        // If bit is currently 1
        // Subtract contributions
        deltaH = -localFields[index];
    }
    else
    {
        // If bit is currently 0
        // Add contributions
        deltaH = localFields[index];
    }

    return deltaH;
}

void deGloria(
    size_t index_i,
    size_t index_j,
    const StateVariable& state,
    std::vector<double>& localFields,
    const std::vector<std::vector<double>>& weights)
{
    double deltaH = 0;
    bool bitState = state.test(index_j);

    if (bitState)
    {
        // If bit is currently 1
        // Subtract contributions REVERSED
        deltaH = weights[index_i][index_j];
    }
    else
    {
        // If bit is currently 0
        // Add contributions REVERSED
        deltaH = -weights[index_i][index_j];
    }

    localFields[index_i] += (double)deltaH;
}

bool ADB (double deltaE, double temperature, Criterion criterion)
{
    double probability = 0.0;
    double beta = 1.0 / temperature;

    if (criterion == METROPOLIS)
    {
        // Metropolis Criterion
        probability = std::exp(-beta * (deltaE - E_off));

        // Cap probability at 1
        probability = std::min(1.0, probability);

        // Generate random double between 0 and 1
        double randomNoise = static_cast<double>(rand()) / (double)RAND_MAX;
        bool accept = randomNoise < probability;
        return accept;
    }
    else if (criterion == GIBBS)
    {
        // Gibbs Criterion
        probability = 1.0 / (1.0 + std::exp(beta * (deltaE - E_off)));

        // Generate random double between 0 and 1
        double randomNoise = static_cast<double>(rand()) / (double)RAND_MAX;
        return randomNoise < probability;
    }
    else 
    {
        return false;
    }
}

bool isLegalTSPTraversal(const StateVariable& state)
{
    std::vector<char> cities = {'A', 'B', 'C', 'D', 'E'};
    std::vector<std::pair<int, char>> visitOrder; // (order, city)
    uint32_t bits = state.toUInt32();
    // only 5 bits should be set
    if (state.count() != 5)
    {
        return false;
    }

    // Check that bitwise AND of all groups equals 31 (0b11111)
    int groupSum = 0; // Start with all bits set

    groupSum = (bits & MASK_A) >> 20 |
               (bits & MASK_B) >> 15 |
               (bits & MASK_C) >> 10 |
               (bits & MASK_D) >> 5  |
               (bits & MASK_E);

    if (groupSum != 31)
    {
        return false;
    }

    // For each city (group of 5 bits)
    for (size_t city = 0; city < 5; city++)
    {
        // Find which bit is set in this group
        for (size_t bit = 0; bit < 5; bit++)
        {
            size_t index = city * 5 + bit;
            if (state.test(index))
            {
                visitOrder.push_back({bit, cities[city]});
                break;
            }
        }
    }

    if (visitOrder.size() != 5)
    {
        // Invalid traversal
        return false;
    }
    
    // This is a legal TSP traversal
    return true;
}

void printTSPTraversal(const StateVariable& state)
{
    std::vector<char> cities = {'A', 'B', 'C', 'D', 'E'};
    std::vector<std::pair<int, char>> visitOrder; // (order, city)
    
    // For each city (group of 5 bits)
    for (size_t city = 0; city < 5; city++)
    {
        // Find which bit is set in this group
        for (size_t bit = 0; bit < 5; bit++)
        {
            size_t index = city * 5 + bit;
            if (state.test(index))
            {
                visitOrder.push_back({bit, cities[city]});
                break;
            }
        }
    }

    if (visitOrder.size() != 5)
    {
        // Invalid traversal
        return;
    }
    
    // Sort by visit order
    std::sort(visitOrder.begin(), visitOrder.end());
    
    // Print the traversal
    std::cout << "TSP Traversal: ";
    for (size_t i = 0; i < visitOrder.size(); i++)
    {
        std::cout << visitOrder[i].second;
        if (i < visitOrder.size() - 1)
            std::cout << "->";
    }
    //std::cout << std::endl;
}

int main() {

    std::cout << std::right;
    currentState.program("0000110000001000001001000"); // [B->E->C->D->A] = 0b 00001 10000 00100 00010 01000
    currentState.print(); std::cout << "\n\n";         // [B->D->E->A->C] = SOLUTION
    // Initialize local fields
    scaleWeightsAndBiases(weights_i_j, biases_i, SCALE);
    initializeLocalFields(currentState, localField_h, weights_i_j, biases_i);

    int legalCount = 0;

    // Main Iteration Loop
    for (int iter = 0; iter < MAX_ITER; iter++)
    {
        int bitFlipIndex = -1;
        for (size_t i = 0; i < MAX_BITS; i++)
        {
            // step 1: calculate deltaE for bit i
            double deltaE = deltaEnergy(i, currentState, localField_h);

            // step 2: decide whether to flip bit i
            bool flip = ADB(deltaE, FIXED_TEMPERATURE, METROPOLIS);

            // step 3: keep only 1 index to flip
            if (flip)
            {
                //std::cout << "Considering flip of bit " << i << " with ΔE = " << deltaE << std::endl;
                if (bitFlipIndex)
                {
                    bool shouldFlip = (rand() % 2) == 1;
                    if (shouldFlip) {
                        bitFlipIndex = i;
                    }
                }
                else
                {
                    bitFlipIndex = i;
                }
            }
        }

        // step 4: flip the bit if needed
        if (bitFlipIndex >= 0)
        {
            currentState.toggle(bitFlipIndex);

            // step 5: update local fields
            for (size_t i = 0; i < MAX_BITS; i++)
            {
                deGloria(i, bitFlipIndex, currentState, localField_h, weights_i_j);
            }

            // Reset E_off
            E_off = 0;
        }
        else
        {
            // Increment E_off
            if (E_off < E_OFF_MAX)
            {
                E_off += E_OFF;
            }
        }

        // Print Telemetry
        if (isLegalTSPTraversal(currentState))
        {
            std::cout << "Iteration:" << std::setw(5) << iter << " | ";
            std::cout << "Energy:" << std::setw(5) << IsingEnergy(localField_h, currentState, weights_i_j) << " | ";
            currentState.print(); std::cout << " | ";
            if (isLegalTSPTraversal(currentState))
            {
                printTSPTraversal(currentState);
                legalCount++;
            }
            std::cout << std::endl;
        }

    }

    std::cout << "\nTotal Legal TSP Traversals Found: " << legalCount << std::endl;

    return 0;
}