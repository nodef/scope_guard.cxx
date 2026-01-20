# Taskflow <img align="right" width="10%" src="https://github.com/taskflow/taskflow/blob/master/image/taskflow_logo.png">

<!--[![Linux Build Status](https://travis-ci.com/taskflow/taskflow.svg?branch=master)](https://travis-ci.com/taskflow/taskflow)-->
[![Ubuntu](https://github.com/taskflow/taskflow/workflows/Ubuntu/badge.svg)](https://github.com/taskflow/taskflow/actions?query=workflow%3AUbuntu)
[![macOS](https://github.com/taskflow/taskflow/workflows/macOS/badge.svg)](https://github.com/taskflow/taskflow/actions?query=workflow%3AmacOS)
[![Windows](https://github.com/taskflow/taskflow/workflows/Windows/badge.svg)](https://github.com/taskflow/taskflow/actions?query=workflow%3AWindows)
[![Wiki](https://github.com/taskflow/taskflow/blob/master/image/api-doc.svg)][documentation]
[![TFProf](https://github.com/taskflow/taskflow/blob/master/image/tfprof.svg)](https://taskflow.github.io/tfprof/)
[![Cite](https://github.com/taskflow/taskflow/blob/master/image/cite-tpds.svg)][TPDS22]

Taskflow helps you quickly write task-parallel programs using modern C++

# Why Taskflow?

Taskflow is faster, more expressive, and easier to integrate than many existing task programming frameworks when handling complex parallel workloads.

![](https://github.com/taskflow/taskflow/blob/master/image/performance.png)

Taskflow lets you quickly implement task decomposition strategies
that incorporate both regular and irregular compute patterns,
together with an efficient *work-stealing* scheduler to optimize your multithreaded performance.

| [Static Tasking](#start-your-first-taskflow-program) | [Subflow Tasking](#create-a-subflow-graph) |
| :------------: | :-------------: |
| ![](https://github.com/taskflow/taskflow/blob/master/image/static_graph.svg) | <img align="right" src="https://github.com/taskflow/taskflow/blob/master/image/dynamic_graph.svg" width="100%"> |

Taskflow supports conditional tasking for you to make rapid control-flow decisions
across dependent tasks to implement cycles and conditions that were otherwise difficult to do
with existing tools.

| [Conditional Tasking](#integrate-control-flow-to-a-task-graph) |
| :-----------------: |
| ![](https://github.com/taskflow/taskflow/blob/master/image/condition.svg) |

Taskflow is composable. You can create large parallel graphs through
composition of modular and reusable blocks that are easier to optimize
at an individual scope.

| [Taskflow Composition](#compose-task-graphs) |
| :---------------: |
|![](https://github.com/taskflow/taskflow/blob/master/image/framework.svg)|

Taskflow supports heterogeneous tasking for you to
accelerate a wide range of scientific computing applications
by harnessing the power of CPU-GPU collaborative computing.

| [Concurrent CPU-GPU Tasking](#offload-a-task-to-a-gpu) |
| :-----------------: |
| ![](https://github.com/taskflow/taskflow/blob/master/image/cudaflow.svg) |


Taskflow provides visualization and tooling needed for profiling Taskflow programs.

| [Taskflow Profiler](https://taskflow.github.io/tfprof) |
| :-----------------: |
| ![](https://github.com/taskflow/taskflow/blob/master/image/tfprof.png) |

We are committed to support trustworthy developments for both academic and industrial research projects
in parallel computing. Check out [Who is Using Taskflow](https://taskflow.github.io/#tag_users) and what our users say:

+ *"Taskflow is the cleanest Task API I've ever seen." [Damien Hocking @Corelium Inc](http://coreliuminc.com)*
+ *"Taskflow has a very simple and elegant tasking interface. The performance also scales very well." [Glen Fraser][totalgee]*
+ *"Taskflow lets me handle parallel processing in a smart way." [Hayabusa @Learning](https://cpp-learning.com/cpp-taskflow/)*
+ *"Taskflow improves the throughput of our graph engine in just a few hours of coding." [Jean-Michaël @KDAB](https://ossia.io/)*
+ *"Best poster award for open-source parallel programming library." [Cpp Conference 2018][Cpp Conference 2018]*
+ *"Second Prize of Open-source Software Competition." [ACM Multimedia Conference 2019](https://tsung-wei-huang.github.io/img/mm19-ossc-award.jpg)*

See a quick poster presentation below and
visit the [documentation][documentation] to learn more about Taskflow.
Technical details can be referred to our [IEEE TPDS paper][TPDS22].

![](https://github.com/taskflow/taskflow/blob/master/image/taskflow-poster.png)

# Installation

Run:

```bash
$ npm i taskflow.cxx
```

And then include `taskflow.hpp` as follows:

```cxx
// main.cxx
#include <taskflow.hpp>  // or, taskflow/taskflow.hpp

int main() { /* ... */ }
```

Finally, compile while adding the path `node_modules/taskflow.cxx` to your compiler's include paths.

```bash
$ clang++ -std=c++20 -I./node_modules/taskflow.cxx main.cxx  # or, use g++
$ g++     -std=c++20 -I./node_modules/taskflow.cxx main.cxx
```

You may also use a simpler approach with the [cpoach](https://www.npmjs.com/package/cpoach.sh) tool, which automatically adds the necessary include paths of all the installed dependencies for your project.

```bash
$ cpoach clang++ -std=c++20 main.cxx  # or, use g++
$ cpoach g++     -std=c++20 main.cxx
```

# Start Your First Taskflow Program

The following program (`simple.cpp`) creates a taskflow of four tasks
`A`, `B`, `C`, and `D`, where `A` runs before `B` and `C`, and `D`
runs after `B` and `C`.
When `A` finishes, `B` and `C` can run in parallel.
Try it live on [Compiler Explorer (godbolt)](https://godbolt.org/z/j8hx3xnnx)!



```cpp
#include <taskflow/taskflow.hpp>  // Taskflow is header-only

int main(){

  tf::Executor executor;
  tf::Taskflow taskflow;

  auto [A, B, C, D] = taskflow.emplace(  // create four tasks
    [] () { std::cout << "TaskA\n"; },
    [] () { std::cout << "TaskB\n"; },
    [] () { std::cout << "TaskC\n"; },
    [] () { std::cout << "TaskD\n"; }
  );

  A.precede(B, C);  // A runs before B and C
  D.succeed(B, C);  // D runs after  B and C

  executor.run(taskflow).wait();

  return 0;
}
```

Taskflow is *header-only* and there is no wrangle with installation.
To compile the program, clone the Taskflow project and
tell the compiler to include the [headers](https://github.com/taskflow/taskflow/blob/master/taskflow/).

```bash
~$ git clone https://github.com/taskflow/taskflow.git  # clone it only once
~$ g++ -std=c++20 examples/simple.cpp -I. -O2 -pthread -o simple
~$ ./simple
TaskA
TaskC
TaskB
TaskD
```

# Visualize Your First Taskflow Program

Taskflow comes with a built-in profiler,
[TFProf](https://taskflow.github.io/tfprof/),
for you to profile and visualize taskflow programs
in an easy-to-use web-based interface.

![](https://github.com/taskflow/taskflow/blob/master/doxygen/images/tfprof.png)

```bash
# run the program with the environment variable TF_ENABLE_PROFILER enabled
~$ TF_ENABLE_PROFILER=simple.json ./simple
~$ cat simple.json
[
{"executor":"0","data":[{"worker":0,"level":0,"data":[{"span":[172,186],"name":"0_0","type":"static"},{"span":[187,189],"name":"0_1","type":"static"}]},{"worker":2,"level":0,"data":[{"span":[93,164],"name":"2_0","type":"static"},{"span":[170,179],"name":"2_1","type":"static"}]}]}
]
# paste the profiling json data to https://taskflow.github.io/tfprof/
```

In addition to execution diagram, you can dump the graph to a DOT format
and visualize it using a number of free [GraphViz][GraphViz] tools.

```
// dump the taskflow graph to a DOT format through std::cout
taskflow.dump(std::cout);
```

<p align="center"><img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/simple.svg"></p>

# Express Task Graph Parallelism

Taskflow empowers users with both static and dynamic task graph constructions
to express end-to-end parallelism in a task graph that
embeds in-graph control flow.

- [Taskflow ](#taskflow-)
- [Why Taskflow?](#why-taskflow)
- [Installation](#installation)
- [Start Your First Taskflow Program](#start-your-first-taskflow-program)
- [Visualize Your First Taskflow Program](#visualize-your-first-taskflow-program)
- [Express Task Graph Parallelism](#express-task-graph-parallelism)
  - [Create a Subflow Graph](#create-a-subflow-graph)
  - [Integrate Control Flow to a Task Graph](#integrate-control-flow-to-a-task-graph)
  - [Offload a Task to a GPU](#offload-a-task-to-a-gpu)
  - [Compose Task Graphs](#compose-task-graphs)
  - [Launch Asynchronous Tasks](#launch-asynchronous-tasks)
  - [Execute a Taskflow](#execute-a-taskflow)
  - [Leverage Standard Parallel Algorithms](#leverage-standard-parallel-algorithms)
- [Supported Compilers](#supported-compilers)
- [Learn More about Taskflow](#learn-more-about-taskflow)
- [License](#license)

## Create a Subflow Graph

Taskflow supports *dynamic tasking* for you to create a subflow
graph from the execution of a task to perform dynamic parallelism.
The following program spawns a task dependency graph parented at task `B`.

```cpp
tf::Task A = taskflow.emplace([](){}).name("A");
tf::Task C = taskflow.emplace([](){}).name("C");
tf::Task D = taskflow.emplace([](){}).name("D");

tf::Task B = taskflow.emplace([] (tf::Subflow& subflow) {
  tf::Task B1 = subflow.emplace([](){}).name("B1");
  tf::Task B2 = subflow.emplace([](){}).name("B2");
  tf::Task B3 = subflow.emplace([](){}).name("B3");
  B3.succeed(B1, B2);  // B3 runs after B1 and B2
}).name("B");

A.precede(B, C);  // A runs before B and C
D.succeed(B, C);  // D runs after  B and C
```

<p align="center"><img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/subflow_join.svg"></p>

## Integrate Control Flow to a Task Graph

Taskflow supports *conditional tasking* for you to make rapid
control-flow decisions across dependent tasks to implement cycles
and conditions in an *end-to-end* task graph.

```cpp
tf::Task init = taskflow.emplace([](){}).name("init");
tf::Task stop = taskflow.emplace([](){}).name("stop");

// creates a condition task that returns a random binary
tf::Task cond = taskflow.emplace(
  [](){ return std::rand() % 2; }
).name("cond");

init.precede(cond);

// creates a feedback loop {0: cond, 1: stop}
cond.precede(cond, stop);
```

<p align="center"><img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/conditional-tasking-1.svg"></p>


## Offload a Task to a GPU

Taskflow supports GPU tasking for you to accelerate a wide range of scientific computing applications by harnessing the power of CPU-GPU collaborative computing using Nvidia CUDA Graph.

```cpp
__global__ void saxpy(size_t N, float alpha, float* dx, float* dy) {
  int i = blockIdx.x*blockDim.x + threadIdx.x;
  if (i < N) {
    y[i] = alpha*x[i] + y[i];
  }
}

// create a CUDA Graph task
tf::Task cudaflow = taskflow.emplace([&]() {
  tf::cudaGraph cg;
  tf::cudaTask h2d_x = cg.copy(dx, hx.data(), N);
  tf::cudaTask h2d_y = cg.copy(dy, hy.data(), N);
  tf::cudaTask d2h_x = cg.copy(hx.data(), dx, N);
  tf::cudaTask d2h_y = cg.copy(hy.data(), dy, N);
  tf::cudaTask saxpy = cg.kernel((N+255)/256, 256, 0, saxpy, N, 2.0f, dx, dy);
  saxpy.succeed(h2d_x, h2d_y)
       .precede(d2h_x, d2h_y);

  // instantiate an executable CUDA graph and run it through a stream
  tf::cudaGraphExec exec(cg);
  tf::cudaStream stream;
  stream.run(exec).synchronize();
}).name("CUDA Graph Task");
```

<p align="center"><img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/saxpy_1_cudaflow.svg"></p>

## Compose Task Graphs

Taskflow is composable.
You can create large parallel graphs through composition of modular
and reusable blocks that are easier to optimize at an individual scope.

```cpp
tf::Taskflow f1, f2;

// create taskflow f1 of two tasks
tf::Task f1A = f1.emplace([]() { std::cout << "Task f1A\n"; })
                 .name("f1A");
tf::Task f1B = f1.emplace([]() { std::cout << "Task f1B\n"; })
                 .name("f1B");

// create taskflow f2 with one module task composed of f1
tf::Task f2A = f2.emplace([]() { std::cout << "Task f2A\n"; })
                 .name("f2A");
tf::Task f2B = f2.emplace([]() { std::cout << "Task f2B\n"; })
                 .name("f2B");
tf::Task f2C = f2.emplace([]() { std::cout << "Task f2C\n"; })
                 .name("f2C");

tf::Task f1_module_task = f2.composed_of(f1)
                            .name("module");

f1_module_task.succeed(f2A, f2B)
              .precede(f2C);
```

<p align="center"><img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/composition.svg"></p>

## Launch Asynchronous Tasks

Taskflow supports *asynchronous* tasking.
You can launch tasks asynchronously to dynamically explore task graph parallelism.

```cpp
tf::Executor executor;

// create asynchronous tasks directly from an executor
std::future<int> future = executor.async([](){
  std::cout << "async task returns 1\n";
  return 1;
});
executor.silent_async([](){ std::cout << "async task does not return\n"; });

// create asynchronous tasks with dynamic dependencies
tf::AsyncTask A = executor.silent_dependent_async([](){ printf("A\n"); });
tf::AsyncTask B = executor.silent_dependent_async([](){ printf("B\n"); }, A);
tf::AsyncTask C = executor.silent_dependent_async([](){ printf("C\n"); }, A);
tf::AsyncTask D = executor.silent_dependent_async([](){ printf("D\n"); }, B, C);

executor.wait_for_all();
```

## Execute a Taskflow

The executor provides several *thread-safe* methods to run a taskflow.
You can run a taskflow once, multiple times, or until a stopping criteria is met.
These methods are non-blocking with a `tf::Future<void>` return
to let you query the execution status.

```cpp
// runs the taskflow once
tf::Future<void> run_once = executor.run(taskflow);

// wait on this run to finish
run_once.get();

// run the taskflow four times
executor.run_n(taskflow, 4);

// runs the taskflow five times
executor.run_until(taskflow, [counter=5](){ return --counter == 0; });

// block the executor until all submitted taskflows complete
executor.wait_for_all();
```

## Leverage Standard Parallel Algorithms

Taskflow defines algorithms for you to quickly express common parallel
patterns using standard C++ syntaxes,
such as parallel iterations, parallel reductions, and parallel sort.

```cpp
tf::Task task1 = taskflow.for_each( // assign each element to 100 in parallel
  first, last, [] (auto& i) { i = 100; }
);
tf::Task task2 = taskflow.reduce(   // reduce a range of items in parallel
  first, last, init, [] (auto a, auto b) { return a + b; }
);
tf::Task task3 = taskflow.sort(     // sort a range of items in parallel
  first, last, [] (auto a, auto b) { return a < b; }
);
```

Additionally, Taskflow provides composable graph building blocks for you to
efficiently implement common parallel algorithms, such as parallel pipeline.

```cpp
// create a pipeline to propagate five tokens through three serial stages
tf::Pipeline pl(num_parallel_lines,
  tf::Pipe{tf::PipeType::SERIAL, [](tf::Pipeflow& pf) {
    if(pf.token() == 5) {
      pf.stop();
    }
  }},
  tf::Pipe{tf::PipeType::SERIAL, [](tf::Pipeflow& pf) {
    printf("stage 2: input buffer[%zu] = %d\n", pf.line(), buffer[pf.line()]);
  }},
  tf::Pipe{tf::PipeType::SERIAL, [](tf::Pipeflow& pf) {
    printf("stage 3: input buffer[%zu] = %d\n", pf.line(), buffer[pf.line()]);
  }}
);
taskflow.composed_of(pl)
executor.run(taskflow).wait();
```


# Supported Compilers

To use Taskflow v4.0.0, you need a compiler that supports C++20:

  + GNU C++ Compiler at least v11.0 with -std=c++20
  + Clang C++ Compiler at least v12.0 with -std=c++20
  + Microsoft Visual Studio at least v19.29 (VS 2019) with /std:c++20
  + Apple Clang (Xcode) at least v13.0 with -std=c++20
  + NVIDIA CUDA Toolkit and Compiler (nvcc) at least v12.0 with host compiler supporting C++20
  + Intel oneAPI DPC++/C++ Compiler at least v2022.0 with -std=c++20

Taskflow works on Linux, Windows, and Mac OS X.

# Learn More about Taskflow

Visit our [project website][Project Website] and [documentation][documentation]
to learn more about Taskflow. To get involved:

  + See [release notes][release notes] to stay up-to-date with newest versions
  + Read the step-by-step tutorial at [cookbook][cookbook]
  + Submit an issue at [GitHub issues][GitHub issues]
  + Find out our technical details at [references][references]
  + Watch our technical talks at YouTube

[![Taskflow Tutorials](https://img.youtube.com/vi/u4vaY0cjzos/0.jpg)](https://www.youtube.com/watch?v=u4vaY0cjzos)

We are committed to support trustworthy developments for
both academic and industrial research projects in parallel
and heterogeneous computing.
If you are using Taskflow, please cite the following paper we published at 2021 IEEE TPDS:

+ Tsung-Wei Huang, Dian-Lun Lin, Chun-Xun Lin, and Yibo Lin, &quot;[Taskflow: A Lightweight Parallel and Heterogeneous Task Graph Computing System](https://tsung-wei-huang.github.io/papers/tpds21-taskflow.pdf),&quot; <i>IEEE Transactions on Parallel and Distributed Systems (TPDS)</i>, vol. 33, no. 6, pp. 1303-1320, June 2022

More importantly, we appreciate all Taskflow [contributors][contributors] and
the following organizations for sponsoring the Taskflow project!

| <!-- --> | <!-- --> | <!-- --> | <!-- --> |
|:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:|
|<img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/utah-ece-logo.png">|<img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/nsf.png"> | <img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/darpa.png"> | <img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/NumFocus.png">|
|<img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/nvidia-logo.png"> | <img src="https://github.com/taskflow/taskflow/blob/master/doxygen/images/uw-madison-ece-logo.png"> | | |

[Taskflow](https://ads.fund/token/0xadf8c696719c904923504683d3f3f7d18774ac06) project is also supported by ADS.FUND.

# License

Taskflow is licensed with the [MIT License](https://github.com/taskflow/taskflow/blob/master/LICENSE).
You are completely free to re-distribute your work derived from Taskflow.

* * *

[Tsung-Wei Huang]:       https://tsung-wei-huang.github.io/
[GitHub releases]:       https://github.com/taskflow/taskflow/releases
[GitHub issues]:         https://github.com/taskflow/taskflow/issues
[GitHub insights]:       https://github.com/taskflow/taskflow/pulse
[GitHub pull requests]:  https://github.com/taskflow/taskflow/pulls
[GraphViz]:              https://www.graphviz.org/
[Project Website]:       https://taskflow.github.io/
[cppcon20 talk]:         https://www.youtube.com/watch?v=MX15huP5DsM
[contributors]:          https://taskflow.github.io/taskflow/contributors.html
[totalgee]:              https://github.com/totalgee
[NSF]:                   https://www.nsf.gov/
[UIUC]:                  https://illinois.edu/
[CSL]:                   https://csl.illinois.edu/
[UofU]:                  https://www.utah.edu/
[documentation]:         https://taskflow.github.io/taskflow/index.html
[release notes]:         https://taskflow.github.io/taskflow/Releases.html
[cookbook]:              https://taskflow.github.io/taskflow/pages.html
[references]:            https://taskflow.github.io/taskflow/References.html
[PayMe]:                 https://www.paypal.me/twhuang/10
[email me]:              mailto:twh760812@gmail.com
[Cpp Conference 2018]:   https://github.com/CppCon/CppCon2018
[TPDS22]:                https://tsung-wei-huang.github.io/papers/tpds21-taskflow.pdf

<br>
<br>


[![](https://raw.githubusercontent.com/qb40/designs/gh-pages/0/image/11.png)](https://wolfram77.github.io)<br>
[![SRC](https://img.shields.io/badge/src-repo-green?logo=Org)](https://github.com/taskflow/taskflow)
[![ORG](https://img.shields.io/badge/org-nodef-green?logo=Org)](https://nodef.github.io)
![](https://ga-beacon.deno.dev/G-RC63DPBH3P:SH3Eq-NoQ9mwgYeHWxu7cw/github.com/nodef/taskflow.cxx)
