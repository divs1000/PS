global a
a = 0
def f(x):
    global a
    a = a + 1
    return (x - 50.4)**2
def frange(start, stop, step):
    while start <= stop:
        yield start
        start += step
# Modified Fibonacci implementation (key changes)
def find_minimum_optimized(f, start=48.5, end=51.5, step=0.1):
    x_values = [round(x, 1) for x in frange(start, end, step)]
    n = len(x_values)
    
    fib = [1, 1]
    while fib[-1] < n:
        fib.append(fib[-1] + fib[-2])
    
    k = len(fib) - 1
    a, b = 0, n-1
    evaluations = 0
    
    while k > 0:
        mid = a + fib[k-1] - 1
        if mid >= b:
            mid = b - 1
        
        if f(x_values[mid]) < f(x_values[mid+1]):
            b = mid
            k -= 1
        else:
            a = mid + 1
            k -= 2
        evaluations += 1  # Only 1 new eval per iteration
        
    return x_values[a], evaluations + 1  # +1 for final check

print(find_minimum_optimized(f))
print(a)