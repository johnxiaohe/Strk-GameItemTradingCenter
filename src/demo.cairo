use starknet::ContractAddress;

const ONE_CONST_VAR: u32 = 3600; 

// 声明drop方法用于回收资源
#[derive(Drop)]
struct Rectangle<T>{
    width: T,
    height: T,
}

trait RectangleTrait<T>{
    fn area(self: @Rectangle<T>) -> T;
}

impl RectangleImpl<T, +Mul<T>, +Copy<T>> of RectangleTrait<T>{
    fn area(self: @Rectangle<T>) -> T{
        *self.height * *self.width
    }
}

fn main(){
    // let arr = array![1,2,3];
    // arr_snp(arr.span());
    // println!("Arr len is {}", arr.len());
    // println!("{}", sum_arr(arr));
    // arr not exist
    
    let rectangle = Rectangle{width: 30_u32, height: 10_u32,};
    println!("Area is {}", rectangle.area());
}

fn arr_snp(arr: Span<u32>){

}

fn sum_arr<T, +AddEq<T>, +core::zeroable<T>, +Drop<T>, +Copy<T>>(mut arr: Span<T>) -> T{
    let mut sum = core::zeroable::zero();
    loop{
        match arr.pop_front() {
            Option::Some(current_value) => {
                sum += current_value;
            },
            Option::None => {
                break;
            },
        };
    };
    sum
}

fn sum_three(a: u32, b: u32, c: u32) -> u32{
    a+b+c
}

fn min(a: u32, b: u32) -> u32{
    if a<=b{
        a
    }else{
        b
    }
}

fn fib(mut a: felt252, mut b: felt252, mut n: felt252) -> felt252{
    loop{
        // goto loop out
        if n == 0{
            break a;
        }

        n -=1;
        let temp = b;
        b = a+b;
        a = temp;
    }
}

#[cfg(test)]
mod tests {
    use super::sum_three;

    #[test]
    fn it_works() {
        assert(sum_three(1,2,3)==6, 'faild!');
    }
}
