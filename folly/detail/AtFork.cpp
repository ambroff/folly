/*
 * Copyright 2017-present Facebook, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#include <folly/detail/AtFork.h>

#include <list>
#include <mutex>

#include <folly/Exception.h>

namespace folly {

namespace detail {

namespace {

struct AtForkTask {
  void* object;
  folly::Function<void()> prepare;
  folly::Function<void()> parent;
  folly::Function<void()> child;
};

class AtForkList {
 public:
  static AtForkList& instance() {
    static auto instance = new AtForkList();
    return *instance;
  }

  static void prepare() noexcept {
    instance().tasksLock.lock();
    auto& tasks = instance().tasks;
    for (auto task = tasks.rbegin(); task != tasks.rend(); ++task) {
      task->prepare();
    }
  }

  static void parent() noexcept {
    auto& tasks = instance().tasks;
    for (auto& task : tasks) {
      task.parent();
    }
    instance().tasksLock.unlock();
  }

  static void child() noexcept {
    auto& tasks = instance().tasks;
    for (auto& task : tasks) {
      task.child();
    }
    instance().tasksLock.unlock();
  }

  std::mutex tasksLock;
  std::list<AtForkTask> tasks;

 private:
  AtForkList() {
    int ret = pthread_atfork(
        &AtForkList::prepare, &AtForkList::parent, &AtForkList::child);
    checkPosixError(ret, "pthread_atfork failed");
  }
};
} // namespace

void AtFork::init() {
  AtForkList::instance();
}

void AtFork::registerHandler(
    void* object,
    folly::Function<void()> prepare,
    folly::Function<void()> parent,
    folly::Function<void()> child) {
  std::lock_guard<std::mutex> lg(AtForkList::instance().tasksLock);
  AtForkList::instance().tasks.push_back(
      {object, std::move(prepare), std::move(parent), std::move(child)});
}

void AtFork::unregisterHandler(void* object) {
  auto& list = AtForkList::instance();
  std::lock_guard<std::mutex> lg(list.tasksLock);
  for (auto it = list.tasks.begin(); it != list.tasks.end(); ++it) {
    if (it->object == object) {
      list.tasks.erase(it);
      return;
    }
  }
}

} // namespace detail
} // namespace folly
