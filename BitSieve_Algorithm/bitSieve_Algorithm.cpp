#include <iostream>
#include <vector>
#include <cstdint>
#include <random>
#include <cassert>

class BitSet32 {
private:
    uint32_t bits = 0;

public:
    void set(int index) {
        if (index >= 0 && index < 32)
            bits |= (1U << index);
    }

    void unset(int index) {
        if (index >= 0 && index < 32)
            bits &= ~(1U << index);
    }

    bool test(int index) const {
        if (index >= 0 && index < 32)
            return (bits >> index) & 1;
        return false;
    }

    void reset() {
        bits = 0;
    }
};
BitSet32 bitset;

std::vector<std::vector<int>> weights = {};
std::vector<int> biases = {};
std::vector<int> localField_h = {};
uint32_t state = 0;

void setRandomState(uint32_t& value) {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<uint32_t> dis(0, UINT32_MAX);
    value = dis(gen);
}

void initializeLocalFields(
    std::vector<int>& localFields,
    const std::vector<std::vector<int>>& weights,
    const std::vector<int>& biases)
{
    
    //Ensure sizes match
    assert(biases.size() == weights.size());

    // Initialize local fields using formula hi = ΣWij + b_i
    for (int i = 0; i < weights.size(); i++)
    {
        int h = biases[i];
        for (int j = 0; j < weights[i].size(); j++)
        {
            h += weights[i][j];
        }
        localFields.push_back(h);
    }

}

int IsingEnergy(
    const std::vector<int>& localFields,
    const BitSet32& bitset,
    const std::vector<std::vector<int>>& weights)
{
    
    int energy = 0;
    int weightSum = 0;
    int biasSum = 0;

    // Sum of Weights
    for (int i = 0; i < weights.size(); i++)
    {
        if (bitset.test(i))
        {
            for (int j = 0; j < weights[i].size();j++)
            {
                if (bitset.test(j))
                {
                    weightSum += weights[i][j];
                }
            }
        }
    }

    // Sum of Biases
    for (int i = 0; i < localFields.size(); i++)
    {
        if (bitset.test(i))
        {
            biasSum += localFields[i];
        }
    }

    energy = -0.1 * (weightSum - biasSum);

    return energy;
}

int deltaEnergy(
    int index,
    const std::vector<int>& localFields,
    const BitSet32& bitset,
    const std::vector<std::vector<int>>& weights)
{
    int deltaE = 0;
    int weightSum = 0;

    // Calculate change in energy when flipping bit at 'index'
    for (int j = 0; j < weights[index].size(); j++)
    {
        if (bitset.test(j))
        {
            weightSum += weights[index][j];
        }
    }

    deltaE = 2 * (localFields[index] + weightSum);

    return deltaE;
}

int main() {
    std::cout << "Hello, World!" << std::endl;
    setRandomState(state);
    std::cout << "Random State: " << state << std::endl;
    return 0;
}