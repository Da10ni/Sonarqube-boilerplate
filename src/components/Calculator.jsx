import { useState } from "react";

const Calculator = () => {
  const [result, setResult] = useState("");
  const [firstNumber, setFirstNumber] = useState("");
  const [secondNumber, setSecondNumber] = useState("");
  const [operation, setOperation] = useState("");

  const add = (a, b) => a + b;
  const subtract = (a, b) => a - b;
  const multiply = (a, b) => a * b;
  const divide = (a, b) => {
    if (b === 0) {
      throw new Error("Cannot divide by zero");
    }
    return a / b;
  };

  const calculate = () => {
    try {
      const num1 = parseFloat(firstNumber);
      const num2 = parseFloat(secondNumber);

      if (isNaN(num1) || isNaN(num2)) {
        setResult("Invalid input");
        return;
      }

      let calculationResult;
      switch (operation) {
        case "add":
          calculationResult = add(num1, num2);
          break;
        case "subtract":
          calculationResult = subtract(num1, num2);
          break;
        case "multiply":
          calculationResult = multiply(num1, num2);
          break;
        case "divide":
          calculationResult = divide(num1, num2);
          break;
        default:
          setResult("Please select an operation");
          return;
      }

      setResult(calculationResult.toString());
    } catch (error) {
      setResult(error.message);
    }
  };

  const clear = () => {
    setResult("");
    setFirstNumber("");
    setSecondNumber("");
    setOperation("");
  };

  return (
    <div className="calculator">
      <h2>React Calculator</h2>

      <div className="inputs">
        <input
          type="number"
          placeholder="First number"
          value={firstNumber}
          onChange={(e) => setFirstNumber(e.target.value)}
          data-testid="first-number"
        />

        <select
          value={operation}
          onChange={(e) => setOperation(e.target.value)}
          data-testid="operation-select"
        >
          <option value="">Select operation</option>
          <option value="add">Add</option>
          <option value="subtract">Subtract</option>
          <option value="multiply">Multiply</option>
          <option value="divide">Divide</option>
        </select>

        <input
          type="number"
          placeholder="Second number"
          value={secondNumber}
          onChange={(e) => setSecondNumber(e.target.value)}
          data-testid="second-number"
        />
      </div>

      <div className="buttons">
        <button onClick={calculate} data-testid="calculate-button">
          Calculate
        </button>
        <button onClick={clear} data-testid="clear-button">
          Clear
        </button>
      </div>

      <div className="result" data-testid="result">
        Result: {result}
      </div>
    </div>
  );
};

export default Calculator;
