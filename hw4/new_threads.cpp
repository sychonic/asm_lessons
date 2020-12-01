#include <iostream>
#include <vector>
#include <omp.h>
using namespace std;


struct trio{
    int x, y, z;
    void print(){
        cout << x << ' ' << y << ' ' << z << '\n';
    }
    trio(){}
    trio(int x_, int y_, int z_){
        x = x_;
        y = y_;
        z = z_;
    }
};


trio a[1000];
int sums = 0, n = 0;
vector <trio> ans;
omp_lock_t locking_buffer;

/*void func(int k){
    sums += a[k]*a[k];
    return;
}*/

void func(int i, int j){
    //cout << omp_get_thread_num() << "thread" << '\n';
    int d1 = a[i].x*a[j].y - a[i].y*a[j].x;
    int d2 = a[i].y*a[j].z - a[i].z*a[j].y;
    int d3 = a[i].x*a[j].z - a[i].z*a[j].x;
    for (int k = j + 1; k < n; ++k){
        int det = a[k].x*d2 - a[k].y*d3 + a[k].z*d1;
        if (det == 0){
            omp_set_lock(&locking_buffer);
            ans.push_back(trio(i + 1, j + 1, k + 1));
            omp_unset_lock(&locking_buffer);
        }
    }
    return;
}

void init(){
    return;
}

int main() {
    omp_init_lock(&locking_buffer);
    cout << "Enter number of 3dim vectors\n";
    cin >> n;
    cout << "Enter vectors one in each line\n";
    for (int i = 0; i < n; ++i){
        cin >> a[i].x >> a[i].y >> a[i].z;
    }
        for (int i = 0; i < n - 2; ++i){
            #pragma omp parallel for
            for (int j = i + 1; j < n - 1; ++j){
                func(i,j);
            }
        }
    omp_destroy_lock(&locking_buffer);
    cout << "Here are all the trios of complanar vectors:\n";
    for (int i = 0; i < ans.size(); ++i){
        ans[i].print();
    }
    return 0;
}
/*

5
0 0 1
0 1 0
1 0 0
0 1 1
4 8 2

6
0 1 1
4 8 2
5 9 1
2 9 3
4 7 5
1 8 2
*/
