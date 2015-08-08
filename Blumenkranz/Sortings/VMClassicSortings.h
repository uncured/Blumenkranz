#ifndef Blumenkranz_VMClassicSortings_h
#define Blumenkranz_VMClassicSortings_h

/*
 Complexity: O(N logN) / O(N logN) / O(N^2) + O(N)
 Unstable
 */
void VMQuickSort(int32_t *unsorted, int32_t endIdx);

/*
 Complexity: O(N logN) / O(N logN) / O(N logN) + O(N)
 Stable
 */
void VMMergeSort(int32_t *unsorted, int32_t startIdx, int32_t endIdx);

/*
 Complexity: O(N) / O(N^2) / O(N^2) + O(1)
 Stable
 */
void VMInsertSort(int32_t *unsorted, int32_t size);

/*
 Complexity: O(N) / O(N^2) / O(N^2) + O(1)
 Stable
 */
void VMBubbleSort(int32_t *unsorted, int32_t size);

/*
 Complexity: O(N logN) / O(N logN) / O(N logN) + O(1)
 Unstable
 */
void VMHeapSort(int32_t *unsorted, int32_t size);

#endif