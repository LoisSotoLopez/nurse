defmodule Nurse.CondMap do
  def put_new_son_of(map, "0", "simple", _side) when map == %{},
    do: %{key: "simple", condition_id: "0S", params: %{}}

  def put_new_son_of(map, "0", son_type, _side) when map == %{} do
    %{
      key: son_type,
      condition_id: "0" <> get_type_id(son_type),
      fst: %{},
      snd: %{}
    }
  end

  def put_new_son_of(
        %{
          key: _key,
          condition_id: parent_id,
          fst: first,
          snd: _second
        },
        parent_id,
        _son_type,
        "first"
      )
      when first != %{},
      do: {:error, :bad_arg, "Parent has 2 childs already"}

  def put_new_son_of(
        %{
          key: _key,
          condition_id: parent_id,
          fst: _first,
          snd: second
        },
        parent_id,
        _son_type,
        "second"
      )
      when second != %{},
      do: {:error, :bad_arg, "Parent has 2 childs already"}

  def put_new_son_of(
        %{
          key: key,
          condition_id: parent_id,
          fst: first,
          snd: second
        },
        parent_id,
        son_type,
        side
      ) do
    case side do
      "first" ->
        %{
          key: key,
          condition_id: parent_id,
          fst: put_new_son_of(first, parent_id, son_type, side),
          snd: second
        }

      "second" ->
        %{
          key: key,
          condition_id: parent_id,
          fst: first,
          snd: put_new_son_of(second, parent_id, son_type, side)
        }
    end
  end

  def put_new_son_of(
        %{
          key: key,
          condition_id: condition_id,
          fst: first,
          snd: second
        },
        parent_id,
        son_type,
        side
      ) do
    condition_id_len = String.length(condition_id)
    parent_id_len = String.length(parent_id)

    case condition_id_len > parent_id_len do
      true ->
        {:error, :wrong_path}

      false ->
        <<head::binary-size(condition_id_len)>> <> rest = parent_id

        case head do
          value when value == condition_id ->
            rest_head = String.at(rest, 0)

            case rest_head do
              "1" ->
                case put_new_son_of(first, parent_id, son_type, side) do
                  {:error, :wrong_path} ->
                    {:error, :wrong_path}

                  map ->
                    %{
                      key: key,
                      condition_id: condition_id,
                      fst: map,
                      snd: second
                    }
                end

              "2" ->
                case put_new_son_of(second, parent_id, son_type, side) do
                  {:error, :wrong_path} ->
                    {:error, :wrong_path}

                  map ->
                    %{
                      key: key,
                      condition_id: condition_id,
                      fst: first,
                      snd: map
                    }
                end
            end

          _ ->
            {:error, :wrong_path}
        end
    end
  end

  def put_new_son_of(
        %{
          condition_id: _condition_id,
          key: _key,
          params: _params
        },
        _parent_id,
        _son_type,
        _side
      ),
      do: {:error, :wrong_path}

  def put_new_son_of(map, parent_id, son_type, "first") when map == %{} do
    %{
      key: son_type,
      condition_id: parent_id <> "1" <> get_type_id(son_type)
    }
    |> Map.merge(get_son_default_map(son_type))
  end

  def put_new_son_of(map, parent_id, son_type, "second") when map == %{} do
    %{
      key: son_type,
      condition_id: parent_id <> "2" <> get_type_id(son_type)
    }
    |> Map.merge(get_son_default_map(son_type))
  end

  def update_condition_params(map, _condition_id, _update) when map == %{},
    do: {:error, :empty_map}

  def update_condition_params(
        %{
          key: _key,
          # TODO:
          condition_id: condition_id,
          fst: _first,
          snd: _second
        },
        condition_id,
        _update
      ) do
    {:error, :wrong_id}
  end

  def update_condition_params(
        %{
          key: key,
          condition_id: condition_id,
          params: params
        },
        condition_id,
        update
      ) do
    %{
      key: key,
      condition_id: condition_id,
      params: Map.merge(params, update)
    }
  end

  def update_condition_params(
        %{
          key: _key,
          condition_id: _condition_id,
          params: _params
        },
        _parent_id,
        _update
      ) do
    {:error, :wrong_path}
  end

  def update_condition_params(
        %{
          key: key,
          condition_id: parent_id,
          fst: first,
          snd: second
        },
        condition_id,
        update
      ) do
    case update_condition_params(first, condition_id, update) do
      error when error in [{:error, :empty_map}, {:error, :wrong_path}, {:error, :wrong_id}] ->
        case update_condition_params(second, condition_id, update) do
          error
          when error in [{:error, :empty_map}, {:error, :wrong_path}, {:error, :wrong_id}] ->
            error

          map ->
            %{
              key: key,
              condition_id: parent_id,
              fst: first,
              snd: map
            }
        end

      map ->
        %{
          key: key,
          condition_id: parent_id,
          fst: map,
          snd: second
        }
    end
  end

  def validate(map) when map == %{}, do: false

  def validate(%{key: _key, condition_id: _condition_id, params: params}) do
    case params do
      map when map == %{} ->
        false

      _ ->
        true
    end
  end

  def validate(%{key: _key, condition_id: _condition_id, first: fst, second: snd}),
    do: validate(fst) and validate(snd)

  defp get_type_id("simple"), do: "S"

  defp get_type_id("and"), do: "A"

  defp get_type_id("or"), do: "O"

  defp get_son_default_map("simple"), do: %{params: %{}}

  defp get_son_default_map(_other), do: %{fst: %{}, snd: %{}}
end
