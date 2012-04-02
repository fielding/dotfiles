# My roco tasks for deploying node.js app to one of my FreeBSD VPS.
# I use Forever to monitor my node processes.

namespace 'deploy', ->
    task 'start', (done) -> run "cd #{roco.currentPath}; forever start #{roco.nodeEntry}"
    task 'stop', (done) -> run "cd #{roco.currentPath}; forever stop #{roco.nodeEntry}"

    task 'restart', (done) -> run "cd #{roco.currentPath}; forever restart #{roco.nodeEntry} ||  forever start #{roco.nodeEntry}"

# Tasks for monitoring the status of Forever processes
namespace 'status', ->
    # Global status tasks
    task 'list', (done) -> run "forever list" 

    # App specific status tasks
    task 'log', ->
        run "tail -n 100 #{roco.sharedPath}/log/#{roco.env}.log"