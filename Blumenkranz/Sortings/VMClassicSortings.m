#import "VMClassicSortings.h"

void vmSwap(int32_t *values, int32_t leftIdx, int32_t rightIdx) {
    int32_t temp = values[leftIdx];
    values[leftIdx] = values[rightIdx];
    values[rightIdx] = temp;
}

void VMQuickSort(int32_t *unsorted, int32_t endIdx) {
    int32_t i = 0;
    int32_t j = endIdx;
    int32_t median = unsorted[endIdx >> 1];
    do {
        while (unsorted[i] < median) { i++; }
        while (unsorted[j] > median) { j--; }
        if (i <= j) {
            vmSwap(unsorted, i, j);
            i++;
            j--;
        }
    } while (i <= j);
    if (j > 0) {
        VMQuickSort(unsorted, j);
    }
    if (i < endIdx) {
        VMQuickSort(unsorted + i, endIdx - i);
    }
}

void vmMerge(int32_t *unsorted, int32_t startIdx, int32_t endIdx, int32_t medianIdx) {
    int32_t i = startIdx;
    int32_t j = medianIdx + 1;
    int32_t *buffer = (int32_t *)malloc(sizeof(int32_t) * (endIdx - startIdx + 1));
    int32_t bufferIdx = 0;
    while (i <= medianIdx && j <= endIdx) {
        if (unsorted[i] < unsorted[j]) {
            buffer[bufferIdx++] = unsorted[i++];
        } else {
            buffer[bufferIdx++] = unsorted[j++];
        }
    }
    while (i <= medianIdx) {
        buffer[bufferIdx++] = unsorted[i++];
    }
    while (j <= endIdx) {
        buffer[bufferIdx++] = unsorted[j++];
    }
    for (int32_t idx = 0; idx < bufferIdx; idx++) {
        unsorted[startIdx + idx] = buffer[idx];
    }
    free(buffer);
    buffer = NULL;
}

void VMMergeSort(int32_t *unsorted, int32_t startIdx, int32_t endIdx) {
    if (endIdx > startIdx) {
        int32_t medianIdx = (startIdx + endIdx) >> 1;
        VMMergeSort(unsorted, 0, medianIdx);
        VMMergeSort(unsorted, medianIdx + 1, endIdx);
        vmMerge(unsorted, startIdx, endIdx, medianIdx);
    }
}

void VMInsertSort(int32_t *unsorted, int32_t size) {
    for (int32_t i = 0; i < size; i++) {
        int32_t j = i - 1;
        int32_t currentValue = unsorted[i];
        for (; j >= 0 && (unsorted[j] > currentValue); j--) {
            unsorted[j + 1] = unsorted[j];
        }
        unsorted[j + 1] = currentValue;
    }
}

void VMBubbleSort(int32_t *unsorted, int32_t size) {
    for (int32_t i = 0; i < size; i++) {
        for (int32_t j = size - 1; j > i; j--) {
            if (unsorted[j] < unsorted[j - 1]) {
                vmSwap(unsorted, j, j - 1);
            }
        }
    }
}

void vmShiftDown(int32_t *unsorted, int32_t nodeIdx, int32_t size) {
    int32_t leftChildIdx = nodeIdx * 2 + 1;
    int32_t rightChildIdx = nodeIdx * 2 + 2;
    int32_t maxChildIdx = leftChildIdx;
    BOOL done = NO;
    while (!done && (leftChildIdx < size)) {
        if ((leftChildIdx == size - 1) || (unsorted[leftChildIdx] > unsorted[rightChildIdx])) {
            maxChildIdx = leftChildIdx;
        } else {
            maxChildIdx = rightChildIdx;
        }
        if (unsorted[nodeIdx] < unsorted[maxChildIdx]) {
            vmSwap(unsorted, nodeIdx, maxChildIdx);
            leftChildIdx = maxChildIdx;
            rightChildIdx = leftChildIdx + 1;
        } else {
            done = YES;
        }
    }
}

void VMHeapSort(int32_t *unsorted, int32_t size) {
    for (int i = size/2 - 1; i>=0; i--) {
        vmShiftDown(unsorted, i, size);
    }
    for (int i = size - 1; i >= 1; i--) {
        vmSwap(unsorted, 0, i);
        vmShiftDown(unsorted, 0, i);
    }
}