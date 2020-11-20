#include <iostream>
#include <thread>
#include <vector>
#include <mutex>

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
mutex m;

/*void func(int k){
    sums += a[k]*a[k];
    return;
}*/

void func(int i, int j){
    int d1 = a[i].x*a[j].y - a[i].y*a[j].x;
    int d2 = a[i].y*a[j].z - a[i].z*a[j].y;
    int d3 = a[i].x*a[j].z - a[i].z*a[j].x;
    for (int k = j + 1; k < n; ++k){
        int det = a[k].x*d2 - a[k].y*d3 + a[k].z*d1;
        if (det == 0){
            m.lock();
            ans.push_back(trio(i, j, k));
            m.unlock();
        }
    }
    return;
}

void init(){
    return;
}

int main() {
    unsigned int thread_num = thread::hardware_concurrency()/2;
    cin >> n;
    vector <thread> tr(thread_num);
    for (int k = 0; k < thread_num; ++k)
        tr[k] = thread(init);
    for (int k = 0; k < thread_num; ++k)
        tr[k].join();
    for (int i = 0; i < n; ++i){
        cin >> a[i].x >> a[i].y >> a[i].z;
    }
    for (int i = 0; i < n - 2; ++i){
        for (int j = i + 1; j < n - 1; ++j){
            //cout << i << ' ' << j << '\n';
            bool no_free_threads = true;
            for (int k = 0; ((no_free_threads) && (k < thread_num)); ++k){
                if ((!(tr[k].joinable()))){
                    tr[k] = thread(func, i, j);
                    no_free_threads = false;
                }
            }
            if (no_free_threads){
                for (int k = 0; k < thread_num; ++k)
                    tr[k].join();
            }
        }
    }

    for (int k = 0; k < thread_num; ++k){
        if (tr[k].joinable())
            tr[k].join();
    }
    for (int i = 0; i < ans.size(); ++i){
        ans[i].print();
    }
    return 0;
}
