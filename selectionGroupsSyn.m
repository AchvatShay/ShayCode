resultsTosave1 = [];
resultsTosave2 = [];
for index = [70, 128]

    branchNumber = 10;
    synPerbranch = 100;
    synActiveTogether = index;
    k = 15;
    permutationTest = 50000;

    test = [];
    for i = 1:permutationTest
        dataMAt = zeros(branchNumber, synPerbranch);
        r =randperm(synPerbranch*branchNumber,synActiveTogether);
        dataMAt(r) = 1;
        testSum = sum(dataMAt,2);

        test(end+1:end+branchNumber) = testSum;
    end

    figure; hold on ;
    h = histogram(test);
    h.Normalization = 'probability';

    distR = h.Values;
    resultsTosave1(end+1) = sum(distR(k+1:end));

    if synActiveTogether <= synPerbranch
        otherM(1) = (nchoosek(synPerbranch,0) .* nchoosek(synPerbranch*branchNumber-synPerbranch, synActiveTogether-0)) ./ (nchoosek(synPerbranch*branchNumber, synActiveTogether));
        for i=1:synActiveTogether
            otherM(i+1) = (nchoosek(synPerbranch,i) .* nchoosek(synPerbranch*branchNumber-synPerbranch, synActiveTogether-i)) ./ (nchoosek(synPerbranch*branchNumber, synActiveTogether));
        end

        resultsTosave2(end+1) = sum(otherM(k+1:end));
    end
end