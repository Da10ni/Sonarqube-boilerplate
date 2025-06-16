import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import Calculator from "../Calculator";

describe("Calculator Component", () => {
  it("renders correctly", () => {
    render(<Calculator />);
    expect(screen.getByText("React Calculator")).toBeInTheDocument();
    expect(screen.getByTestId("first-number")).toBeInTheDocument();
    expect(screen.getByTestId("second-number")).toBeInTheDocument();
    expect(screen.getByTestId("operation-select")).toBeInTheDocument();
    expect(screen.getByTestId("calculate-button")).toBeInTheDocument();
  });

  it("performs addition correctly", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "5" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "add" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent("Result: 8");
  });

  it("performs subtraction correctly", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "10" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "subtract" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent("Result: 7");
  });

  it("performs multiplication correctly", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "4" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "multiply" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent("Result: 12");
  });

  it("performs division correctly", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "15" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "divide" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent("Result: 5");
  });

  it("handles division by zero", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "10" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "0" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "divide" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent(
      "Result: Cannot divide by zero"
    );
  });

  it("handles invalid input", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "abc" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "add" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent(
      "Result: Invalid input"
    );
  });

  it("clears all fields when clear button is clicked", () => {
    render(<Calculator />);

    // Fill in some values
    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "5" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.change(screen.getByTestId("operation-select"), {
      target: { value: "add" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    // Clear everything
    fireEvent.click(screen.getByTestId("clear-button"));

    expect(screen.getByTestId("first-number")).toHaveValue(null);
    expect(screen.getByTestId("second-number")).toHaveValue(null);
    expect(screen.getByTestId("operation-select")).toHaveValue("");
    expect(screen.getByTestId("result")).toHaveTextContent("Result: ");
  });

  it("shows message when no operation is selected", () => {
    render(<Calculator />);

    fireEvent.change(screen.getByTestId("first-number"), {
      target: { value: "5" },
    });
    fireEvent.change(screen.getByTestId("second-number"), {
      target: { value: "3" },
    });
    fireEvent.click(screen.getByTestId("calculate-button"));

    expect(screen.getByTestId("result")).toHaveTextContent(
      "Result: Please select an operation"
    );
  });
});
