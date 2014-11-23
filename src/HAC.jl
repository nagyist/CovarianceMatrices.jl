
function k_tr{T}(x::T) 
  if(abs(x)<= one(T) || isnan(0/0))
    return one(T)
  else  
    return zero(T)
  end 
end 

k_bt{T}(x::T) = max(one(T)-abs(x), zero(T))

function k_pr{T}(x::T) 
  ax = abs(x)
  if(ax>one(T))
    return(zero(Float64))
  elseif ax<=.5
    return(1-6*x^2+6*ax^3)
  else
    return(2*(1-ax)^3)
  end 
end 

function k_qs{T <: Number}(x::T) 
  if(isequal(x, zero(eltype(x))))
    return one(Float64)
  else 
   return (25/(12*π²*x^2))*(sin(sixπ*x/5)/(sixπ*x/5)-cos(sixπ*x/5))
 end 
end 

function k_th{T <: Number}(x::T)
  ax = abs(x)
  if(ax < one(T))
    return (1 + cos(πx))/2
  else 
    return zero(T)
  end 
end

##############################################################################
##
## Optimal band-width
##
##############################################################################


type TruncatedKernel <: HAC
  kernel::Function
  bw::Function
end

type BartlettKernel <: HAC
  kernel::Function    
  bw::Function
end

type ParzenKernel <: HAC
  kernel::Function   
  bw::Function
end

type TukeyHanningKernel <: HAC
  kernel::Function   
  bw::Function
end


type QuadraticSpectralKernel <: HAC
  kernel::Function    
  bw::Function
end

typealias TRK TruncatedKernel
typealias BTK BartlettKernel
typealias PRK ParzenKernel
typealias THK ParzenKernel
typealias QSK QuadraticSpectralKernel



TruncatedKernel()    = TRK(k_tr, optimalbw_ar_one)
BartlettKernel()     = BTK(k_bt, optimalbw_ar_one)
ParzenKernel()       = PRK(k_pr, optimalbw_ar_one)
TukeyHanningKernel() = THK(k_th, optimalbw_ar_one)
QuadraticSpectralKernel() = QSK(k_qs, optimalbw_ar_one)

TruncatedKernel(bw::Number)    = TRK(k_tr, (x, k) -> float(bw))
BartlettKernel(bw::Number)     = BTK(k_bt, (x, k) -> float(bw))
ParzenKernel(bw::Number)       = PRK(k_pr, (x, k) -> float(bw))
TukeyHanningKernel(bw::Number) = THK(k_th, (x, k) -> float(bw))
QuadraticSpectralKernel(bw::Number) = QSK(k_qs, (x, k) -> float(bw))

function bandwidth(k::HAC, X::AbstractMatrix)
    return floor(k.bw(X, k))
end 

function bandwidth(k::QuadraticSpectralKernel, X::AbstractMatrix)
    return k.bw(X, k)
end 

kernel(k::HAC, x::Real) = k.kernel(x)

function Γ(X::AbstractMatrix, j::Int64)
  T, p = size(X)
  Q = zeros(eltype(X), p, p)
  if j>=0
    for h=1:p, s = 1:h
     for t = j+1:T    
      @inbounds Q[s, h] = Q[s, h] + X[t, s]*X[t-j, h]
     end 
    end   
  else
    for h=1:p, s = 1:h
     for t = -j+1:T    
      @inbounds Q[s,h] = Q[s,h] + X[t+j, s]*X[t,h]
     end 
    end 
  end 
  return Q
end 

function Γ!(Q::AbstractMatrix, X::AbstractMatrix, j::Int64)
  T, p = size(X)  
  if j>=0
    for h=1:p, s = 1:h
     for t = j+1:T    
      @inbounds Q[s, h] = Q[s, h] + X[t, s]*X[t-j, h]
     end 
    end   
  else
    for h=1:p, s = 1:h
     for t = -j+1:T    
      @inbounds Q[s,h] = Q[s,h] + X[t+j, s]*X[t,h]
     end 
    end 
  end   
end 


function vcov(X::AbstractMatrix, k::HAC)
  ## How to deal with optimal bandwidth?
  bw = bandwidth(k, X)
  T, p = size(X)
  Q = zeros(p, p)  
  for j=-bw:bw    
    #Q += kernel(k, j/bw).*Γ(X, int(j))
    Base.BLAS.axpy!(kernel(k, j/bw), Γ(X, int(j)), Q)
  end 
  return Symmetric(Q/T)
end 

function vcov(X::AbstractMatrix, k::QuadraticSpectralKernel)
  ## How to deal with optimal bandwidth?
  bw = bandwidth(k, X)
  T, p = size(X)  
  Q = zeros(eltype(X), p, p)  
  for j=-T:T
    Base.BLAS.axpy!(kernel(k, j/bw), Γ(X, int(j)), Q)    
    ## Q += kernel(k, j/bw).*Γ(X, int(j))
  end 
  return Symmetric(Q/T)
end 

